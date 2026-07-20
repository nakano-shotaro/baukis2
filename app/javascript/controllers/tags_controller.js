import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = [ "input" ]
  static values = { messageId: String }

  // 1. 🔴 タグの追加処理（Enterキー検知）
  add(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      const label = this.inputTarget.value.trim()
      
      if (label) {
        this.sendTagRequest("POST", label)
        this.inputTarget.value = "" // 入力欄をクリア
      }
    }
  }

  // 2. 🔴 タグの削除処理（バツ印クリック検知）
  remove(event) {
    event.preventDefault()
    // HTML側の data-tags-label-param から値を取得
    const label = event.params.label
    
    if (label) {
      this.sendTagRequest("DELETE", label)
    }
  }

  // 3. モダンダッシュボード標準の超軽量非同期Fetch通信
  async sendTagRequest(method, label) {
    const url = `/messages/${this.messageIdValue}/tag`
    const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

    try {
      const response = await fetch(url, {
        method: method,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "X-CSRF-Token": csrfToken,
          "X-Requested-With": "XMLHttpRequest" // reject_non_xhr を安全に通過
        },
        body: new URLSearchParams({ label: label })
      })

      if (response.ok) {
        // 🔴 通信成功後、Turbo Driveの仕組みを利用して画面の該当箇所だけを爆速で自動再描画（リフレッシュ）
        Turbo.visit(window.location.href, { action: "replace" })
      } else {
        console.error("タグの保存に失敗しました")
      }
    } catch (error) {
      console.error("通信エラー:", error)
    }
  }
}
