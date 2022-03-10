スパコンのホスト「at025」を例に D-easy 環境の構築手順を示す。前提として at025 には SSH でログイン可能であるものとする。

## サーバ内のディレクトリ構成と必要なディレクトリの作成

構築する D-easy 環境のディレクトリ構成は以下の通り。

- /home/w3deasy
    - mongo
        - log （MongoDBのログ）
        - db （MongoDBのデータディレクトリ）
    - deasy
        - production
            - log （Rails, Unicornのログ）
            - tmp （Unicornのpidsファイル、session ファイルなど）
        - staging
            - log （Rails, Unicornのログ）
            - tmp （Unicornのpidsファイル、session ファイルなど）
    - singularity
        - deasy （Singularity イメージ・起動スクリプト置き場）
    - submission （サブミッション出力ディレクトリ）
    - submission-staging （ステージング環境用の submission ディレクトリ）
    - ncbi-taxonomy （taxdump.tar.gz 置き場）

MongoDB、Unicorn を起動する前に以下のディレクトリを作成しておく必要がある。

    # at025上にて 
    $ mkdir -p ~/mongo/{log,db}
    $ mkdir -p ~/deasy/production/{log,tmp}
    $ mkdir -p ~/deasy/staging/{log,tmp}
    $ mkdir -p ~/singularity/deasy
    $ mkdir -p ~/submission
    $ mkdir -p ~/submission-staging
    $ mkdir -p ~/ncbi-taxonomy

## Singularity コンテナイメージの作成と配置

### コンテナイメージの作成

D-easy の Singularity イメージを作成するには、Singularity が動作する環境で以下のコマンドを実行する。

    $ cd ~
    $ git clone git@github.com:ddbj/sakura.git
    $ cd sakura/
    $ cd singularity/
    # 本番環境向けのコンテナイメージを作成
    $ ./scripts/build.sh production

ステージング環境向けのコンテナイメージを作成する場合は `./scripts/build.sh production` の代わりに `./scripts/build.sh staging` を実行する。

    # ステージング環境向けのコンテナイメージを作成
    $ ./scripts/build.sh staging

`scripts/build.sh` が完了すると `~/sakura/singularity/images` ディレクトリに deasy-production.simg ファイル（ステージング環境向けの場合は deasy-staging.simg）が作成される。

### コンテナイメージの配置

Singularity コンテナイメージ (deasy-production.simg and/or deasy-staging.simg) を `$HOME/singularity/deasy` ディレクトリに配置する。

    $ scp image/deasy-production.simg at025:~/singularity/deasy
    $ scp image/deasy-staging.simg at025:~/singularity/deasy

### 起動スクリプトの配置

MongoDB, Unicorn コンテナインスタンスの開始および起動スクリプト (start_mongo.sh, start_unicorn.sh) を `$HOME/singularity/deasy` ディレクトリに配置する。

    $ scp scripts/start_mongo.sh at025:~/singularity/deasy
    $ scp scripts/start_unicorn.sh at025:~/singularity/deasy

以下、at025上での実行手順。

## MongoDBを起動

（production 環境用）

    $ cd ~/singularity/deasy
    $ ./start_mongo.sh production

（staging 環境用）

    $ cd ~/singularity/deasy
    $ ./start_mongo.sh staging

起動を確認

    $ singularity instance.list
    DAEMON NAME      PID      CONTAINER IMAGE
    MongoProduction  32823    /gpfs1/lustre2/home/w3deasy/singularity/deasy/deasy-production.simg
    MongoStaging     32399    /gpfs1/lustre2/home/w3deasy/singularity/deasy/deasy-staging.simg
    
    $ ps x | grep mongod | grep -v grep
    32451 ?        Sl     0:48 mongod --replSet deasy-staging --dbpath /home/w3deasy/mongo/db/57020/ --fork --logpath /home/w3deasy/mongo/log/57020.log --port 57020
    32561 ?        Sl     0:45 mongod --replSet deasy-staging --dbpath /home/w3deasy/mongo/db/57021/ --fork --logpath /home/w3deasy/mongo/log/57021.log --port 57021
    32695 ?        Sl     0:49 mongod --replSet deasy-staging --dbpath /home/w3deasy/mongo/db/57022/ --fork --logpath /home/w3deasy/mongo/log/57022.log --port 57022
    32865 ?        Sl     0:43 mongod --replSet deasy --dbpath /home/w3deasy/mongo/db/57010/ --fork --logpath /home/w3deasy/mongo/log/57010.log --port 57010
    32982 ?        Sl     0:45 mongod --replSet deasy --dbpath /home/w3deasy/mongo/db/57011/ --fork --logpath /home/w3deasy/mongo/log/57011.log --port 57011
    33099 ?        Sl     0:43 mongod --replSet deasy --dbpath /home/w3deasy/mongo/db/57012/ --fork --logpath /home/w3deasy/mongo/log/57012.log --port 57012

MongoDBのレプリケーション設定

（production 環境用）

    $ singularity exec instance://MongoProduction mongo --port 57010
    > rs.initiate()
    > rs.add("localhost:57011")
    > rs.add("localhost:57012")

（staging 環境用）

    $ singularity exec instance://MongoStaging mongo --port 57020
    > rs.initiate()
    > rs.add("localhost:57021")
    > rs.add("localhost:57022")

`rs.status()` で PRIMARY、SECONDARY になっていることを確認する。

## Unicornの起動

（production 環境用）

    $ cd ~/singularity/deasy
    $ ./start_unicorn.sh production

（staging 環境用）

    $ cd ~/singularity/deasy
    $ ./start_unicorn.sh staging

起動を確認

    $ singularity instance.list
    DAEMON NAME      PID      CONTAINER IMAGE
    MongoProduction  32823    /gpfs1/lustre2/home/w3deasy/singularity/deasy/deasy-production.simg
    MongoStaging     32399    /gpfs1/lustre2/home/w3deasy/singularity/deasy/deasy-staging.simg
    UnicornProduction 33588    /gpfs1/lustre2/home/w3deasy/singularity/deasy/deasy-production.simg
    UnicornStaging   33263    /gpfs1/lustre2/home/w3deasy/singularity/deasy/deasy-staging.simg
    
    $ ps x | grep unicorn | grep -v grep
    33303 ?        Sl     0:07 unicorn_rails master -p 3001 -c config/unicorn.rb -E production --path /submission -D
    33514 ?        Sl     0:00 unicorn_rails worker[0] -p 3001 -c config/unicorn.rb -E production --path /submission -D
    33517 ?        Sl     0:01 unicorn_rails worker[1] -p 3001 -c config/unicorn.rb -E production --path /submission -D
    33520 ?        Sl     0:00 unicorn_rails worker[2] -p 3001 -c config/unicorn.rb -E production --path /submission -D
    33523 ?        Sl     0:01 unicorn_rails worker[3] -p 3001 -c config/unicorn.rb -E production --path /submission -D
    33526 ?        Sl     0:00 unicorn_rails worker[4] -p 3001 -c config/unicorn.rb -E production --path /submission -D
    33529 ?        Sl     0:00 unicorn_rails worker[5] -p 3001 -c config/unicorn.rb -E production --path /submission -D
    33532 ?        Sl     0:01 unicorn_rails worker[6] -p 3001 -c config/unicorn.rb -E production --path /submission -D
    33535 ?        Sl     0:00 unicorn_rails worker[7] -p 3001 -c config/unicorn.rb -E production --path /submission -D
    33626 ?        Sl     0:04 unicorn_rails master -p 3000 -c config/unicorn.rb -E production --path /submission -D
    33647 ?        Sl     0:00 unicorn_rails worker[0] -p 3000 -c config/unicorn.rb -E production --path /submission -D
    33650 ?        Sl     0:00 unicorn_rails worker[1] -p 3000 -c config/unicorn.rb -E production --path /submission -D
    33653 ?        Sl     0:01 unicorn_rails worker[2] -p 3000 -c config/unicorn.rb -E production --path /submission -D
    33656 ?        Sl     0:01 unicorn_rails worker[3] -p 3000 -c config/unicorn.rb -E production --path /submission -D
    33659 ?        Sl     0:00 unicorn_rails worker[4] -p 3000 -c config/unicorn.rb -E production --path /submission -D
    33662 ?        Sl     0:00 unicorn_rails worker[5] -p 3000 -c config/unicorn.rb -E production --path /submission -D
    33665 ?        Sl     0:00 unicorn_rails worker[6] -p 3000 -c config/unicorn.rb -E production --path /submission -D
    33668 ?        Sl     0:01 unicorn_rails worker[7] -p 3000 -c config/unicorn.rb -E production --path /submission -D

## 各種データのインポート

D-easy (Rails) のタスクを実行するため、Unicorn 用インスタンスを使用する。

（production 環境用）

    $ cp /gpfs1/dpl0/ddbjshare/public/ftp.ncbi.nih.gov/ncbi_taxonomy/taxonomydb/taxdump.tar.gz ~/ncbi-taxonomy
    $ singularity run instance://UnicornProduction import_taxonomy
    $ singularity run instance://UnicornProduction import_journal
    $ singularity run instance://UnicornProduction import_kddi
    $ singularity run instance://UnicornProduction import_ncbi

（staging 環境用）

    $ cp /gpfs1/dpl0/ddbjshare/public/ftp.ncbi.nih.gov/ncbi_taxonomy/taxonomydb/taxdump.tar.gz ~/ncbi-taxonomy
    $ singularity run instance://UnicornStaging import_taxonomy
    $ singularity run instance://UnicornStaging import_journal
    $ singularity run instance://UnicornStaging import_kddi
    $ singularity run instance://UnicornStaging import_ncbi

## インデックスの作成

（production 環境用）

    $ singularity run instance://UnicornProduction mongo_create_indexes

（staging 環境用）

    $ singularity run instance://UnicornStaging mongo_create_indexes

## ログローテーションの設定

（ログファイルはat025とat026とで共有されているため、ログのローテーションはat025でのみ行う）

logrotate.confファイルをat025へ配備。

```
scp logrotate.conf.production at025:~/deasy/production/logrotate.conf
scp logrotate.conf.staging at025:~/deasy/staging/logrotate.conf
```

logrotateコマンドを実行してstateファイルを初期化しておく（初回実行の場合はログのローテーションは行われずstateファイルの作成のみが行われる）

```
/usr/sbin/logrotate -s /home/w3deasy/deasy/production/logrotate.status /home/w3deasy/deasy/production/logrotate.conf
/usr/sbin/logrotate -s /home/w3deasy/deasy/staging/logrotate.status /home/w3deasy/deasy/staging/logrotate.conf
```

at025のcrontabへ以下を登録する。

```
0 1 1 * * /usr/sbin/logrotate -s /home/w3deasy/deasy/production/logrotate.status /home/w3deasy/deasy/production/logrotate.conf > /dev/null
0 1 1 * * /usr/sbin/logrotate -s /home/w3deasy/deasy/production/logrotate.status /home/w3deasy/deasy/production/logrotate.conf > /dev/null
```

## cron の設定

### Unicorn

    # Unicorn (production)
    @reboot /bin/bash -l -c 'cd ~/singularity/deasy && ./start_unicorn.sh production'
    
    # Unicorn (staging)
    @reboot /bin/bash -l -c 'cd ~/singularity/deasy && ./start_unicorn.sh staging'

### MongoDB

    # MongoDB (production)
    @reboot /bin/bash -l -c 'cd ~/singularity/deasy && ./start_mongo.sh production'
    
    # MongoDB (staging)
    @reboot /bin/bash -l -c 'cd ~/singularity/deasy && ./start_mongo.sh staging'

### 各種インポート

    # taxdump
    30 23 * * * /bin/bash -l -c 'cp /gpfs1/dpl0/ddbjshare/public/ftp.ncbi.nih.gov/ncbi_taxonomy/taxonomydb/taxdump.tar.gz ~/ncbi-taxonomy'
    
    # Import (production)
    0 0 * * * /bin/bash -l -c 'singularity instance.list | grep -q UnicornProduction && singularity run instance://UnicornProduction import_taxonomy'
    5 0 * * * /bin/bash -l -c 'singularity instance.list | grep -q UnicornProduction && singularity run instance://UnicornProduction sakura2db_write_generated'
    0 0 1 * * /bin/bash -l -c 'singularity instance.list | grep -q UnicornProduction && singularity run instance://UnicornProduction import_kddi'
    0 0 1 * * /bin/bash -l -c 'singularity instance.list | grep -q UnicornProduction && singularity run instance://UnicornProduction import_ncbi'
    0 0 1 * * /bin/bash -l -c 'singularity instance.list | grep -q UnicornProduction && singularity run instance://UnicornProduction import_journal'
    0 1 * * * /bin/bash -l -c 'singularity instance.list | grep -q UnicornProduction && singularity run instance://UnicornProduction mongo_create_indexes'

    # Import (staging)
    0 0 * * * /bin/bash -l -c 'singularity instance.list | grep -q UnicornStaging && singularity run instance://UnicornStaging import_taxonomy'
    5 0 * * * /bin/bash -l -c 'singularity instance.list | grep -q UnicornStaging && singularity run instance://UnicornStaging sakura2db_write_generated'
    0 0 1 * * /bin/bash -l -c 'singularity instance.list | grep -q UnicornStaging && singularity run instance://UnicornStaging import_kddi'
    0 0 1 * * /bin/bash -l -c 'singularity instance.list | grep -q UnicornStaging && singularity run instance://UnicornStaging import_ncbi'
    0 0 1 * * /bin/bash -l -c 'singularity instance.list | grep -q UnicornStaging && singularity run instance://UnicornStaging import_journal'
    0 1 * * * /bin/bash -l -c 'singularity instance.list | grep -q UnicornStaging && singularity run instance://UnicornStaging mongo_create_indexes'


### ログローテーション

```
0 1 1 * * /usr/sbin/logrotate -s /home/w3deasy/deasy/production/logrotate.status /home/w3deasy/deasy/production/logrotate.conf > /dev/null
0 1 1 * * /usr/sbin/logrotate -s /home/w3deasy/deasy/staging/logrotate.status /home/w3deasy/deasy/staging/logrotate.conf > /dev/null
```