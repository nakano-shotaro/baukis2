import { Controller } from "@hotwired/stimulus"
import Tagify from "@yaireo/tagify"

export default class extends Controller {
  connect() {
    // コントローラーが紐付いた input 要素を Tagify UI に変換
    this.tagify = new Tagify(this.element, {
      // 必要に応じてオプション（最大タグ数など）を設定
      // originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(',')
    })
  }

  disconnect() {
    // 画面遷移（Turbo）時の重複を防ぐため破棄処理を行う
    if (this.tagify) {
      this.tagify.destroy()
    }
  }
}
