import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="memo-autosave"
export default class extends Controller {
  static targets = ["content", "status"]
  static values = { url: String }

  connect() {
    this.lastSaved = this.contentTarget.value
    this.saving = false
    this.timer = null
  }

  scheduleSave(event) {
    if (event?.isComposing) return

    clearTimeout(this.timer)
    this.setStatus("未保存")

    this.timer = setTimeout(() => this.save(), 1000)
  }

  async save() {
    clearTimeout(this.timer)

    if (this.saving) return

    const content = this.contentTarget.value

    if (content === this.lastSaved) return

    this.saving = true
    this.setStatus("保存中...")

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector(
            'meta[name="csrf-token"]'
          ).content
        },
        body: JSON.stringify({ memo: { content } })
      })

      if (!response.ok) throw new Error("Save failed")

      this.lastSaved = content
      this.setStatus("保存済み", "saved")
    } catch {
      this.setStatus("保存に失敗しました")
    } finally {
      this.saving = false

      if (this.contentTarget.value !== content) {
        this.scheduleSave()
      }
    }
  }

  setStatus(message, state = "idle") {
    this.statusTarget.textContent = message
    this.statusTarget.dataset.state = state
  }

  disconnect() {
    clearTimeout(this.timer)
  }
}
