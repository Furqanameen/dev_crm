import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mobile-menu"
export default class extends Controller {
  static targets = ["menu", "button"]

  connect() {
    // Close menu when clicking outside
    document.addEventListener('click', this.closeOnClickOutside.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.closeOnClickOutside.bind(this))
  }

  toggle() {
    this.menuTarget.classList.toggle('show')
  }

  close() {
    this.menuTarget.classList.remove('show')
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}
