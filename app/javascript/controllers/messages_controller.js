import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "badge" ]

  connect() {
    // 画面に要素が存在する場合、初回の実行と定期実行を開始
    if (this.hasBadgeTarget) {
      this.updateUnprocessedCount()
      // 1分ごとに定期実行 (60000ミリ秒)
      this.interval = setInterval(() => this.updateUnprocessedCount(), 60000)
    }
  }

  disconnect() {
    // 画面遷移時にタイマーをクリアしてメモリリークを防ぐ
    if (this.interval) {
      clearInterval(this.interval)
    }
  }

  updateUnprocessedCount() {
    const path = this.badgeTarget.dataset.path

    fetch(path, { headers: { "X-Requested-With": "XMLHttpRequest" } })
      .then(response => {
        if (!response.ok) throw new Error("Network response was not ok")
        return response.json()
      })
      .then(data => {
        if (data === 0) {
          this.badgeTarget.textContent = ""
        } else {
          this.badgeTarget.textContent = `(${data})`
        }
      })
      .catch(() => {
        // エラー（未ログイン等）の際にログイン画面へリダイレクト
        window.location.href = "/login"
      })
  }
}