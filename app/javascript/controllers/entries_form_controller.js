import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "approved", "canceled", "formApproved", "formNotApproved", "formCanceled", "formNotCanceled", "form" ]

  submit(event) {
    event.preventDefault()

    const approved = []
    const notApproved = []
    const canceled = []
    const notCanceled = []

    // 承認チェックボックスの処理
    this.approvedTargets.forEach((elem) => {
      const entryId = elem.dataset.entryId
      if (elem.checked) {
        approved.push(entryId)
      } else {
        notApproved.push(entryId)
      }
    })

    // キャンセルチェックボックスの処理
    this.canceledTargets.forEach((elem) => {
      const entryId = elem.dataset.entryId
      if (elem.checked) {
        canceled.push(entryId)
      } else {
        notCanceled.push(entryId)
      }
    })

    // 隠しフィールドへの値の設定
    this.formApprovedTarget.value = approved.join(":")
    this.formNotApprovedTarget.value = notApproved.join(":")
    this.formCanceledTarget.value = canceled.join(":")
    this.formNotCanceledTarget.value = notCanceled.join(":")

    // フォームの送信
    this.formTarget.submit()
  }
}