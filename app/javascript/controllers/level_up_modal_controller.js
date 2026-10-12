import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="level-up-modal"
export default class extends Controller {
  static values = {
    auto: { type: Boolean, default: true },
    level: Number,
    delay: { type: Number, default: 1500 },
    duration: { type: Number, default: 8000 }
  }

  connect() {
    this.isOpen = false
    this.showTimer = null
    this.closeTimer = null

    // Turboキャッシュ対策
    this.beforeCacheHandler = () => this.beforeCacheHandler()

    document.addEventListener(
      "turbo:before-cache",
      this.beforeCacheHandler
    )

    // 初回アクセス用のみ自動表示
    if (this.autoValue) {
      this.showTimer = setTimeout(() => {
        this.show()
      }, this.delayValue)
    }
  }

  show(event) {
    // 主導表示の場合は対象レベルを確認する
    if (!this.autoValue) {
      if (event?.detail?.level !== this.levelValue) {
        return
      }
    }

    if (this.isOpen) return

    this.isOpen = true

    this.element.classList.remove("hidden")
    this.element.classList.add("flex")
    this.element.setAttribute("aria-hidden", "false")

    // 指定時間が経過したら閉じる
    this.closeTimeer = setTimeout(() => {
      this.close()
    }, this.durationValue)
  }

  // モーダルを閉じる
  close() {
    if (!this.isOpen) return

    this.hide()

    // 通常レベルアップの場合はゲージに通知する
    if (!this.autoValue) {
      this.dispatch("closed", {
        target: window,
        detail: { level: this.levelValue }
      })
    }
  }

  // 表示を隠す共通処理
  hide() {
    this.isOpen = false

    this.element.classList.add("hidden")
    this.element.classList.remove("flex")
    this.element.setAttribute("aria-hidden", "true")

    clearTimeout(this.closeTimer)
    this.closeTimer = null
  }

  // Turboに保存する前に非表示にする
  beforeCache() {
    this.hide()

    // 戻る操作で初回モーダルを再表示しない
    this.autoValue = false

    clearTimeout(this.showTimer)
  }

  disconnect() {
    clearTimeout(this.showTimer)
    clearTimeout(this.closeTimer)

    document.removeEventListener(
      "turbo:before-cache",
      this.beforeCacheHandler
    )
  }
}
