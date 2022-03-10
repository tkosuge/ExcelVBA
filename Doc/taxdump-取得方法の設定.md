NCBI Taxonomy database dump は cron の日次ジョブにより `/gpfs1/dpl0/ddbjshare/public/ftp.ncbi.nih.gov/ncbi_taxonomy/taxonomydb/` ディレクトリ内の `taxdump.tar.gz` ファイルが `~/ncbi-taxonomy` ディレクトリにコピーされたのち、MongoDB にインポートされる。crontab の記述は以下のようになっている。当該設定については「Singularity コンテナを利用した D-easy 環境構築手順」も参照のこと。

```
30 23 * * * /bin/bash -l -c 'cp /gpfs1/dpl0/ddbjshare/public/ftp.ncbi.nih.gov/ncbi_taxonomy/taxonomydb/taxdump.tar.gz ~/ncbi-taxonomy'
```

## 取得元の変更

D-easy が動作するホスト以外の場所から `taxdump.tar.gz` を取得する場合の設定。

### 外部からの取得：スパコンからの Secure Copy

スパコン外で D-easy を動作させ、スパコン上のファイルを取得する。

- スパコンのホストを `at025` とし、SSH でパスフレーズなしでログインが可能であるものとする
- `taxdump.tar.gz` はスパコン上の `/gpfs1/dpl0/ddbjshare/public/ftp.ncbi.nih.gov/ncbi_taxonomy/taxonomydb` ディレクトリに存在するものとする
- `scp` コマンドでファイルを取得する

```
30 23 * * * /bin/bash -l -c 'scp at025:/gpfs1/dpl0/ddbjshare/public/ftp.ncbi.nih.gov/ncbi_taxonomy/taxonomydb/taxdump.tar.gz ~/ncbi-taxonomy
```

### 外部からの取得：NCBI Taxonomy FTP

- `curl` コマンドでファイルを取得する

```
30 23 * * * /bin/bash -l -c 'curl ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz > ~/ncbi-taxonomy/taxdump.tar.gz'
```

## コピー先の変更

取得したアーカイブ保存先ディレクトリを `~/d-easy/ncbi-taxonomy` 以外の場所に変更する設定。この設定はコンテナ内の `config/settings.yml` に静的に記述されているため、変更する場合はコンテナの再ビルドが必要となる。

以下、開発環境構築手順に従い、リポジトリのクローンが作成されているものとする。

### 設定変更

- `config/settings.yml.production` の７行目 `taxonomy_path` を任意のディレクトリに書き換える。(production 環境の場合。staging 環境の場合は `settings.yml.staging` ファイル。）
例：

```
taxonomy_path: '/opt/sakura/tmp'
```

この設定は**コンテナ内の D-easy (Rails) から認識されるパス**である点に注意が必要。

### 変更内容をリポジトリにコミット・プッシュする

```
$ git add config/settings.yml.production
$ git commit -m "taxonomy_path 設定の変更"
$ git push origin develop
```

### コンテナイメージを再ビルド・配置

運用手順書の「デプロイ手順」に従い、コンテナイメージをビルド・配置する。

### cron ジョブの変更

上記設定に合わせて cron の設定も変更する。以下の設定はホストの `~/deasy/tmp` がコンテナの `/opt/sakura/tmp` ディレクトリにバインドマウントされるものと想定している。

```
30 23 * * * /bin/bash -l -c 'cp /gpfs1/dpl0/ddbjshare/public/ftp.ncbi.nih.gov/ncbi_taxonomy/taxonomydb/taxdump.tar.gz ~/deasy/tmp'
```
