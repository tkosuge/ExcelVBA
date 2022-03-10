## 【注意】

MongoDB4.0対応を試みたもののリリースには間に合わなかったため平成30年度のリリースの時点でのMongoDBのバージョンは（4.0ではなく）3.6である。

平成30年度以降の開発の中で4.0へバージョンアップする際にご参照ください。

## 手順

環境構築手順書に準じて設定・動作するプロダクション環境において、Singularity コンテナのイメージ差し替えによりMongoDBのバージョンを v3.6 から v4.0 へ更新する際の手順を示す。

Unicorn は動作させたまま（すなわち D-easy を稼働させたまま）でアップグレードすることも可能であるが、そもそもコンテナイメージを差し替えることになるので、すべてのコンテナインスタンスを停止＆起動する。

## 前提となる環境

- Unicorn
    - インスタンス名: UnicornProduction
    - ポート番号: 3000
- MongoDB
    - インスタンス名: MongoProduction
    - レプリカセット名: deasy
    - ポート番号: 57010, 57011, 57012

## 手順

現在の v3.6 が入ったコンテナイメージ。 

    $ cd ~/singularity/deasy
    $ ls
    deasy-production.simg  start_monogo.sh  start_unicorn.sh

Unicorn を停止。

    $ singularity instance.stop UnicornProduction

MongoDB を停止。

    $ singularity instance.stop MongoProduction

ここで v4.0 が入っているコンテナイメージに差し替え。

    $ mv deasy-production.simg deasy-production.simg.bak
    $ cp /path/to/new/deasy-production.simg ./

v4.0 の MongoDB を起動。

    $ ./start_mongo.sh production

適当な mongod プロセスに接続し、Primary を確認する。

    $ singularity exec instance://MongoProduction mongo --port 57010 --eval "rs.status()"
    (略)
            "_id" : 1,
    	    "name" : "localhost:57011",
            "health" : 1,
            "state" : 1,
            "stateStr" : "PRIMARY",
    (略)

今回はポート 57011 が Primary なので、ポート 57011 に接続して v4.0 の機能を有効化する。

    $ singularity exec instance://MongoProduction mongo --port 57011
    // 一応確認してみる。この時点では FCV3.6
    > db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )
    {
        "featureCompatibilityVersion" : {
    	    "version" : "3.6"
        },
        "ok" : 1,
        "operationTime" : Timestamp(1551259339, 1),
        "$clusterTime" : {
            "clusterTime" : Timestamp(1551259339, 1),
            "signature" : {
                "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
                "keyId" : NumberLong(0)
            }
        }
    }
    
    // FCV4.0 を有効化
    > db.adminCommand( { setFeatureCompatibilityVersion: "4.0" } )
    {
        "ok" : 1,
        "operationTime" : Timestamp(1551259443, 2),
        "$clusterTime" : {
            "clusterTime" : Timestamp(1551259443, 2),
            "signature" : {
                "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
                "keyId" : NumberLong(0)
            }
        }
    }
    
    > exit

新しいコンテナの Unicorn を起動する。

    $ ./start_unicorn.sh production

レプリカセットのアップグレードに関するさらなる詳細な情報等については、公式のドキュメント ([https://docs.mongodb.com/manual/release-notes/4.0-upgrade-replica-set/](https://docs.mongodb.com/manual/release-notes/4.0-upgrade-replica-set/)) も参照のこと。