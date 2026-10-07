import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="level-up-modal"
export default class extends Controller {
  static values = {
    delay: { type: Number, default: 1500 },
    duration: { type: Number, default: 8000 }
  }

  connect() {
    this.showTimer = setTimeout(() => {
      this.show()

      this.closeTimer = setTimeout(() => {
        this.close()
      }, this.durationValue)
    }, this.delayValue)
  }

  show() {
    this.element.classList.remove("hidden")
    this.element.classList.add("flex")
  }

  close() {
    this.element.classList.add("hidden")
    this.element.classList.remove("flex")
  }

  disconnect() {
    clearTimeout(this.showTimer)
    clearTimeout(this.closeTimer)
  }
}
