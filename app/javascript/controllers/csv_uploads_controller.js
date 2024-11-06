import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["results"]

  connect() {
    this.resultsTarget.classList.add("hidden")
  }

  showResults() {
    this.resultsTarget.classList.remove("hidden")
  }
}