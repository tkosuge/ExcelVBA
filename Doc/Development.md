# 開発環境構築手順

## 事前準備

* Ruby 2.3系をインストール
* MongoDB 3.4系をインストール
* MongoDBを起動しておく
    * `mongod --config /usr/local/etc/mongod.conf`

## 構築手順

注： 新スパコンでの taxdump の場所は /gpfs1/dpl0/ddbjshare/public/ftp.ncbi.nih.gov/ncbi_taxonomy/taxonomydb/taxdump.tar.gz になる予定

1. git clone git@github.com:ddbj/sakura.git
2. cd sakura
3. bundle install
4. cp config/settings.yml.local config/settings.yml
5. cp config/templates.rb.local config/templates.rb
6. cp config/common_rules.rb.local config/common_rules.rb
7. cp config/mongoid.yml.local config/mongoid.yml
8. mkdir tmp
9. scp web11.ddbj.nig.ac.jp:/usr/local/db/taxonomy/ncbi-taxonomy/taxdump.tar.gz tmp/
10. bundle exec rake import:taxonomy
11. bundle exec rake import:country:kddi
12. bundle exec rake import:country:ncbi
13. bundle exec rake import:journal
14. bundle exec rails s

## ローカル環境での Unicorn の起動

Qualifier二重登録系のバグ(https://github.com/ddbj/sakura/issues/528 など)を再現するには複数の更新リクエストを同時にさばく必要があるのだが、Webrickなどを利用していると1度に1リクエストしかさばけないためこれらのバグを再現することができない。そんな時は複数リクエストを同時にさばけるUnicornを利用する。

ローカル環境でのUnicornの起動は以下の手順で行う。

1. config/unicorn_local.rb を作成

以下の内容の config/unicorn_local.rb を作成する。

```
listen 3000
worker_processes 16
timeout 180
```

2. unicorn を起動

作成した config/unicorn_local.rb を指定して unicorn を起動する。

```
$ cd ~/sakura
$ unicorn -c config/unicorn_local.rb
```

## macOS 上での Vagrant+Singularity 環境構築手順

### SingularityのホストとなるUbuntu環境を作成

```
cd ~/
mkdir singularity-host
cd singularity-host/
vagrant init ubuntu/bionic64
vagrant up
vagrant ssh
```

### UbuntuへSingularityをインストール

```
sudo apt update
sudo apt-get install python dh-autoreconf build-essential libarchive-dev
git clone https://github.com/sylabs/singularity.git
cd singularity
git fetch --all
git checkout 2.6.1
./autogen.sh
./configure --prefix=/usr/local --sysconfdir=/etc
make
sudo make install
```

Singularityがインストールされたことを確認。

```
$ singularity --version
2.6.1-HEAD.9103f015
```

### コンテナイメージの作成

事前に Vagrant 上の Ubuntu で sh-keygen コマンドを使って ssh キーペアを作成し、公開鍵を Github へ登録しておく。

```
$ ssh-keygen
$ cat ~/.ssh/id_rsa.pub
（ここで表示される公開鍵をGithubへ登録しておく)
```

sakura を clone し、D-easyコンテナ作成スクリプト (sh scripts/build.sh production) を実行する。

```
vagrant ssh
cd ~
git clone git@github.com:ddbj/sakura.git
cd sakura
# Singularity 向けの作業が develop へマージされたら不要になる予定
git checkout singularity
cd singularity
sh scripts/build.sh production
```

sakura/singularity/image/deasy-production.simg ファイルが作成されていればOK。

### D-easy起動方法
[「deasy.nig.ac.jp で Singularity 化した D-easy を動かした際の手順・各種設定など」](https://docs.google.com/document/d/1cCic4ckCTCmnVap5YyL0uPdnFcr8XEm9SFEs4iVT8vI/) を参照。

(注) 「Singularity コンテナを利用した D-easy 環境構築手順」ができたら参照先をそちらに差し替える
