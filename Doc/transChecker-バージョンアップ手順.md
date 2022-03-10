transChecker のモジュールは D-easy のソース中に含まれており、バージョンアップを行う場合はリポジトリの更新およびコンテナの再ビルドが必要となる。

以下、開発環境構築手順に従い、リポジトリのクローンが作成されているものとする。

## transChecker の取得

[MSS データファイル用チェックツール](https://www.ddbj.nig.ac.jp/ddbj/mss-tool.html) のページ等より、`transChecker.tar.gz` を取得し、アーカイブを展開しておく。

    $ cd /tmp
    $ tar xzf transChecker.tar.gz
    $ ls -R transChecker
    jar             license.txt     transChecker.sh
    
    transChecker/jar:
    transChecker.jar

## D-easy の transChecker を更新

D-easy のソースツリーの `vendor/tools/transchecker` ディレクトリ以下の内容を、アーカイブを展開した中身で置き換える。なお実際に D-easy で使用されているのは `jar/transChecker.jar` のみ。

     $ cp -R transChecker/* ~/sakura/vendor/tools/transchecker 

## 変更内容をリポジトリにコミット・プッシュする

    $ cd ~/sakura
    $ git add vendor/tools/transchecker
    $ git commit -m "transChecker の更新"
    $ git push origin develop

## **コンテナイメージを再ビルド・配置**

運用手順書の「デプロイ手順」に従い、コンテナイメージをビルド・配置する。

## 補足

`config/settings.yml` 内の `jar_path` を変更すれば任意の場所（コンテナからアクセス可能であれば）に `transChecker.jar` を配置することも可能であるが、いずれにせよコンテナの再ビルドが必要であることと、transChecker のバージョン管理が無秩序になってしまう可能性もあるため推奨しない。