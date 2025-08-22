import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "template"]
  
  preview() {
    this.previewTarget.innerHTML = ""
    const files = Array.from(this.inputTarget.files)
    
    if (files.length > 10) {
      alert("You can only upload up to 10 images")
      this.inputTarget.value = ""
      return
    }
    
    files.forEach((file, index) => {
      if (file.type.startsWith("image/")) {
        const reader = new FileReader()
        
        reader.onload = (e) => {
          const template = this.templateTarget.content.cloneNode(true)
          const img = template.querySelector("img")
          const removeBtn = template.querySelector("button")
          
          img.src = e.target.result
          img.alt = file.name
          
          removeBtn.addEventListener("click", () => {
            this.removeImage(index)
          })
          
          this.previewTarget.appendChild(template)
        }
        
        reader.readAsDataURL(file)
      }
    })
  }
  
  removeImage(index) {
    const dt = new DataTransfer()
    const files = Array.from(this.inputTarget.files)
    
    files.forEach((file, i) => {
      if (i !== index) {
        dt.items.add(file)
      }
    })
    
    this.inputTarget.files = dt.files
    this.preview()
  }
}