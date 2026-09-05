// フラッシュメッセージ自動非表示機能
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.element.remove()
    }, 3000)
  }
}
