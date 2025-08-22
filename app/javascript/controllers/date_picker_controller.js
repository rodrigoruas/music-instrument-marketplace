import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startDate", "endDate", "price", "availability", "submitButton"]
  static values = { instrumentId: String, dailyRate: Number }
  
  connect() {
    // Set minimum date to today
    const today = new Date().toISOString().split('T')[0]
    this.startDateTarget.min = today
    this.endDateTarget.min = today
  }
  
  updateEndDateMin() {
    if (this.startDateTarget.value) {
      this.endDateTarget.min = this.startDateTarget.value
      if (this.endDateTarget.value && this.endDateTarget.value < this.startDateTarget.value) {
        this.endDateTarget.value = this.startDateTarget.value
      }
    }
    this.checkAvailability()
  }
  
  async checkAvailability() {
    if (!this.startDateTarget.value || !this.endDateTarget.value) {
      return
    }
    
    const url = `/instruments/${this.instrumentIdValue}/availability`
    const params = new URLSearchParams({
      start_date: this.startDateTarget.value,
      end_date: this.endDateTarget.value
    })
    
    try {
      const response = await fetch(`${url}?${params}`)
      const data = await response.json()
      
      if (data.available) {
        this.availabilityTarget.innerHTML = `
          <div class="text-green-600 flex items-center">
            <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
            </svg>
            Available for selected dates
          </div>`
        this.priceTarget.innerHTML = `Total: ${data.formatted_price}`
        this.submitButtonTarget.disabled = false
        this.submitButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
      } else {
        this.availabilityTarget.innerHTML = `
          <div class="text-red-600 flex items-center">
            <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
            </svg>
            Not available for selected dates
          </div>`
        this.priceTarget.innerHTML = ""
        this.submitButtonTarget.disabled = true
        this.submitButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
      }
    } catch (error) {
      console.error("Error checking availability:", error)
    }
  }
}