transChecker で使用する Java の実行環境はコンテナ内に含まれており、バージョンの変更を行う場合はコンテナの再ビルドが必要となる。

以下、開発環境構築手順に従い、リポジトリのクローンが作成されているものとする。

## Java の RPM パッケージダウンロード URL の取得

[Java のダウンロードページ](https://java.com/ja/download/manual.jsp)にアクセスし、Linux x64 RPM のリンクの URL をコピーする。

## Singularity レシピファイルの更新

D-easy のソースツリーの `singularity/Singularity` ファイルの125行目付近、`%post` セクションの先頭にある `java_download_url` の値を、前項でコピーした URL に置き換える。

    java_download_url='https://javadl.oracle.com/webapps/download/AutoDL?BundleId=XXX'

この状態でコンテナのビルドを実行し、正常にRPMがダウンロードされることを確認する。

    $ cd ~/sakura/singularity
    $ scripts/build.sh production
    $ rm stage image/*.simg

## 変更内容をリポジトリにコミット・プッシュする

    $ cd ~/sakura
    $ git add singularity/Singularity
    $ git commit -m "Java の更新"
    $ git push origin develop

## コンテナイメージを再ビルド・配置

運用手順書の「デプロイ手順」に従い、コンテナイメージをビルド・配置する。

## 補足

`config/settings.yml` 内の `java` の値を変更すれば（コンテナからアクセス可能であれば）任意の場所にある java 実行バイナリを指定することも可能であるが、いずれにせよコンテナの再ビルドが必要であることと、Singularity ホストの環境が無秩序になってしまう可能性もあるため推奨しない。