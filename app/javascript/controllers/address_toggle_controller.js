import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["homeCheckbox", "workCheckbox", "homeFields", "workFields"]

  connect() {
    this.toggleHomeAddress()
    this.toggleWorkAddress()
  }

  toggleHomeAddress() {
    const checked = this.homeCheckboxTarget.checked
    this.#toggleFields(this.homeFieldsTarget, checked)
  }

  toggleWorkAddress() {
    const checked = this.workCheckboxTarget.checked
    this.#toggleFields(this.workFieldsTarget, checked)
  }

  // private
  //#toggleFields(fieldset, enabled) {
    //fieldset.querySelectorAll("input, select, textarea").forEach(field => {
      //field.disabled = !enabled
    //})
  //} 

  #toggleFields(fieldset, checked) {
    fieldset.querySelectorAll("input, select, textarea").forEach((field) => {
      field.disabled = !checked
  })   

    if (checked) { 
      fieldset.style.display = ""
    } else {
      fieldset.style.display = "none"
    }
  }
} 