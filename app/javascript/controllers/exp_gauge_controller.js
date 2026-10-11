import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "bar", "progress", "level",
    "current", "required", "remaining",
    "levelUp", "earned"
  ]

  static values = {
    play: Boolean,
    startLevel: Number,
    startExp: Number,
    requirements: Array,
    finalLevel: Number,
    finalExp: Number
  }

  // HTMLと接続されたとき
  connect() {
    this.frameId = null
    this.earnedTimer = null

    this.requirements = this.requirementsValue

    // Turboのキャッシュ対策
    this.beforeCacheHandler = () => this.beforeCache()
    document.addEventListener(
      "turbo:before-cache",
      this.beforeCacheHandler
    )

    if (this.requirements.length === 0) return

    // イベントがない場合は最新値をそのまま表示
    const reducedMotion = window.matchMedia(
      "(prefers-reduced-motion: reduce)"
    ).matches

    // アニメーションの必要がない場合
    if (!this.playValue) {
      this.finish()
      this.hideEarned()
      return
    }

    // EXP獲得メッセージを3秒間表示
    this.showEarnedFor(3000)

    // 視覚効果を減らす設定の場合
    if (reducedMotion) {
      this.finish()
      return
    }

    // アニメーションの初期設定
    this.stepIndex = 0
    this.phase = "fill"
    this.phaseStartedAt = null

    this.fromExp = this.startExpValue
    this.toExp = this.requirements.length === 1
      ? this.finalExpValue
      : this.requirements[0]

    // 再生開始
    this.frameId = requestAnimationFrame(
      (time) => this.tick(time)
    )
  }

  // アニメーションの各フレームで実行
  tick(time) {
    if (this.phaseStartedAt === null) {
      this.phaseStartedAt = time
    }

    if (this.phase === "fill") {
      const duration = 800
      const elapsed = time - this.phaseStartedAt
      const progress = Math.min(elapsed / duration, 1)

      // 終わりに向かって減速する
      const eased = 1 - Math.pow(1 - progress, 3)

      const exp = this.fromExp +
        (this.toExp - this.fromExp) * eased

      const level = this.startLevelValue + this.stepIndex
      const required = this.requirements[this.stepIndex]

      this.render(level, exp, required)

      // ゲージが今回の目標に到達
      if (progress >= 1) {

        // 最終レベルまで到達したら終了
        if (this.stepIndex === this.requirements.length - 1) {
          this.finish()
          return
        }

        // レベルアップ演出へ
        this.phase = "levelUp"
        this.phaseStartedAt = time
        this.levelUpTarget.classList.remove("hidden")
      }

    } else if (this.phase === "levelUp") {

      // 満タンのゲージを450ms表示
      if (time - this.phaseStartedAt >= 450) {
        this.levelUpTarget.classList.add("hidden")

        // 次のレベルに進む
        this.stepIndex += 1
        this.phase = "fill"
        this.phaseStartedAt = null

        this.fromExp = 0

        const isLast =
          this.stepIndex === this.requirements.length - 1

        this.toExp = isLast
          ? this.finalExpValue
          : this.requirements[this.stepIndex]

        // 次のレベルのゲージを0から表示
        this.render(
          this.startLevelValue + this.stepIndex,
          0,
          this.requirements[this.stepIndex]
        )

        // 余りEXPが0ならここで終了
        if (isLast && this.finalExpValue === 0) {
          this.finish()
          return
        }
      }
    }

    // 次の描画を予約
    this.frameId = requestAnimationFrame(
      (nextTime) => this.tick(nextTime)
    )
  }

  // ゲージと数値を画面に反映
  render(level, exp, required) {
    const displayedExp = Math.round(exp)
    const percent = Math.min(
      Math.max((exp / required) * 100, 0),
      100
    )

    this.levelTarget.textContent = `Lv. ${level}`
    this.barTarget.style.width = `${percent}%`

    this.currentTarget.textContent = displayedExp
    this.requiredTarget.textContent = required
    this.remainingTarget.textContent =
      Math.max(required - displayedExp, 0)

    this.progressTarget.setAttribute(
      "aria-valuenow", displayedExp
    )
    this.progressTarget.setAttribute(
      "aria-valuemax", required
    )
  }

  // アニメーションを終了して最終状態を表示
  finish() {
    this.stop()

    this.render(
      this.finalLevelValue,
      this.finalExpValue,
      this.requirements[this.requirements.length - 1]
    )

    this.levelUpTarget.classList.add("hidden")

    // 再生済みにする
    this.playValue = false
  }

  // EXP獲得メッセージを一定時間表示
  showEarnedFor(duration) {
    clearTimeout(this.earnedTimer)

    this.earnedTarget.classList.remove("hidden")

    this.earnedTimer = setTimeout(() => {
      this.hideEarned()
    }, duration)
  }

  // EXP獲得メッセージを非表示
  hideEarned() {
    clearTimeout(this.earnedTimer)
    this.earnedTimer = null

    this.earnedTarget.classList.add("hidden")
  }

  // Turboがページをキャッシュする前に実行
  beforeCache() {
    if (this.requirements.length > 0) {
      this.finish()
    }

    this.hideEarned()
  }

  // 実行中の描画を取り消す
  stop() {
    if (this.frameId !== null) {
      cancelAnimationFrame(this.frameId)
      this.frameId = null
    }
  }

  // HTMLとの接続が切れたとき
  disconnect() {
    this.stop()
    this.hideEarned()

    document.removeEventListener(
      "turbo:before-cache",
      this.beforeCacheHandler
    )
  }
}
