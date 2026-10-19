import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "title"]

  static values = {
    auto: Boolean,
    waitForExp: Boolean,
    titles: Object
  }

  connect() {
    this.expPending = this.waitForExpValue
    this.queuedType = null

    // Turboキャッシュ対策
    this.beforeCacheHandler = () => this.close()

    document.addEventListener(
      "turbo:before-cache",
      this.beforeCacheHandler
    )

    // 両方の体験枠を終了している場合は自動表示
    if (this.autoValue) {
      this.requestOpen("all")
    }
  }

  // ボタン操作による表示
  open(event) {
    const type =
      event.currentTarget.dataset.guestLimitType || "all"

    this.requestOpen(type)
  }

  // EXP演出中はモーダル表示を待機
  requestOpen(type) {
    if (this.expPending) {
      this.queuedType = this.autoValue ? "all" : type
      return
    }

    this.show(type)
  }

  // EXP演出完了イベントを受け取る
  expFinished() {
    if (!this.expPending) return

    this.expPending = false

    if (this.queuedType) {
      const type = this.queuedType
      this.queuedType = null
      this.show(type)
    }
  }

  // モーダル表示
  show(type) {
    if (this.dialogTarget.open) return

    // Rails Helperから渡されたタイトルを取得
    const title = this.titlesValue[type] || this.titlesValue.all

    this.titleTarget.textContent = title
    this.dialogTarget.showModal()
  }

  // モーダルを閉じる
  close() {
    if (this.dialogTarget.open) {
      this.dialogTarget.close()
    }
  }

  disconnect() {
    this.close()

    document.removeEventListener(
      "turbo:before-cache",
      this.beforeCacheHandler
    )
  }
}
