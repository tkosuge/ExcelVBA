D-easy のメール送信時に利用するSMTPサーバーの接続設定の変更手順を示す。これらの設定はコンテナ内の `config/settings.yml` に静的に記述されているため、変更する場合はコンテナの再ビルドが必要となる。

以下、開発環境構築手順に従い、リポジトリのクローンが作成されているものとする。

## 設定変更

`config/settings.yml.production` の21行目以降、smtp 以下に記述されている設定を任意に変更する。(production 環境の場合。staging 環境の場合は settings.yml.staging ファイル。）

    smtp:
      address:              smtp.gmail.com
      port:                 587
      domain:               g.nig.ac.jp
      user_name:            submission@g.nig.ac.jp
      password:             secret_password
      authentication:       plain
      enable_starttls_auto: true

各項目の設定内容は以下の通り。

- `address`: SMTPサーバーのアドレス
- `port`: SMTPサーバーのポート
- `domain`: HELO コマンドで送信するドメイン名
- `user_name`:  SMTP認証のユーザー名
- `password`: SMTP認証のパスワード
- `authentication`: SMTP認証の種類。`plain`（平文パスワード送信）、`login`（パスワードのBase64エンコード）、`cram_md5`（チャレンジ&レスポンス型認証＋MD5アルゴリズムによるメッセージダイジェスト）のいずれか
- `enable_starttls_auto`: STARTTLSが有効かどうかを検出して自動的に有効にする

## **変更内容をリポジトリにコミット・プッシュする**

    $ git add config/settings.yml.production
    $ git commit -m "SMTP 設定の変更"
    $ git push origin develop

## **コンテナイメージを再ビルド・配置**

運用手順書の「デプロイ手順」に従い、コンテナイメージをビルド・配置する。