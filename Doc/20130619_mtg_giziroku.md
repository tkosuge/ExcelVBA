## 複数Feature時に Location / Qualifier が空の場合はアノテーションファイルに出力しない

- Feature のアノテーションファイルへの出力を Location や Qualifier の有無で判別する事に違和感がある
- 各Entry の Feature毎にチェックボックスを用意し、そこでアノテーションへの出力を制御するようにする方が良い
- チェックしていると出力し、チェックしていない場合は出力しないようにし、また、チェックしていない場合はテーブルの方もグレイにしたい

## ファイルアップロードで読み込まないブロックを定義できるようにする
- ignore_keys.yml を変更して試してもらう必要あり
- スパコン上に本開発用の環境を用意する

## templates.rb

- Feature 及びその Feature に属する Qualifier の共通ルールを用意しておく必要がある(半年 or 1年単位で変更)
- division では (extended_division や annotation_type も?)、上記で用意した Feature のどれを利用するか を宣言する
- extended_division や annotation_type では、 Feaute に属するQualifier や Qualifier のデフォルト値を共通ルールから上書くルールを宣言する
- annotation_type では、division で宣言している利用 Feature について、同じ Feature を複数所持できるような書き方もできるようにする必要がある

## QualifierValue の入力制限

- 必要な入力制限の一覧をご用意頂いた -> QualifierValueの制限値指定.xlsx
- 選択型はすぐに対応できそう
- 現在のフリーフォーマットでは、利用者がまず入力できないであろう所から優先的にやると良いかも
- 永和側でどう進めていくか検討

## 次回お打ち合わせ

7月9日(火) 14:30 〜