MongoDB データベースのダンプ、リストアによる D-easy データベースのバックアップと復元、ならびにデータ移行の手順を以下に示す。

## 前提条件

* MongoDB サーバーおよびクライアントツールのバージョンは v3.4 以降
* バックアップ対象 MongoDB
  * ホスト名: host1
  * ポート番号: 27018
  * DB名: deasy_production 
* リストア対象 MongoDB
  * ホスト名: host2
  * ポート番号: 57010

## バックアップ（ダンプ）

`mongodump` コマンドによりデータのダンプを行う。

* `--host host1`: ホスト名の指定（host1 上で実行する場合は指定不要） 
* `--port 27018`: ポート番号の指定
* `-d deasy_production`: ダンプ対象の DB 名
* `-o ~/dump`: ダンプデータを出力するディレクトリ名。存在しない場合は自動的に作成される

### 通常の動作環境の場合

```
$ mongodump --host host1 --port 27018 -d deasy_production -o ~/dump
```

### コンテナでの運用環境の場合（コンテナ内の mongodump を使う場合）

```
$ cd ~/singularity/deasy
$ singularity exec deasy-production.simg mongodump --host localhost --port 27018 -d deasy_production -o ~/dump
```

出力を確認する。

```
$ ls ~/dump
deasy_production
$ ls ~/dump/deasy_production/
countries.bson           journals.bson              taxonomies.bson
countries.metadata.json  journals.metadata.json     taxonomies.metadata.json
entries.bson             submissions.bson
entries.metadata.json    submissions.metadata.json
```

## リストア

`mongorestore` コマンドによりデータのリストア行う。mongod はすでに起動しているものとする。

* `--host host2`: ホスト名の指定（host2 上で実行する場合は指定不要） 
* `--port 57010`: ポート番号の指定
* `-d deasy_production`: リストア先の DB 名
* `~/dump/deasy_production/`: ダンプデータが格納されたディレクトリ名

### 通常の動作環境の場合

```
$ mongorestore --host host2 --port 57010 -d deasy_production ~/dump/deasy_production/
```

### コンテナでの運用環境の場合（コンテナ内の mongorestore を使う場合）

```
$ cd ~/singularity/deasy
$ singularity exec deasy-production.simg mongorestore --host host2 --port 57010 -d deasy_production ~/dump/deasy_production/
```

データベースを確認する。（レプリカセットの場合のデータベースのリストアップは通常 PRIMARY 上のみ実行可能。）

```
$ mongo --host host2 --port 57010
deasy:PRIMARY> show dbs
admin              0.000GB
config             0.000GB
deasy_production   0.207GB
local              0.175GB
```

## インデックスの作成

ダンプデータにはインデックスの情報は含まれていないため、リストア先で改めてインデックスを作成する。以下はコンテナでの運用環境での手順。

```
# インスタンスを使用する場合
$ singularity run instance://UnicornProduction mongo_create_indexes

# インスタンスを使用しない、インスタンスを開始していない場合
$ cd ~/singularity/deasy
$ singularity run -B "$HOME/deasy/production/log:/opt/sakura/log,$HOME/deasy/production/tmp:/opt/sakura/tmp" deasy-production.simg mongo_create_indexes
```

## 注意点など
* レプリカセットのノードに対してダンプ・リストアを行う場合、そのノードが PRIMARY か SECONDARY であるかは問われない。
* リストア先に同名のデータベースが既に存在している場合、エラーにはならずにそのデータベースに上書きで書き込まれるため注意が必要。上書きで何が起こるか確実に把握している場合以外は、既存のデータは退避する、データパスを変更してサーバーを起動するなど対処する必要がある。
* 原則、データのダンプは他のアプリケーションがアクセスしていない状態で行う。どうしてもデータの変更が生じる可能性のある状態でダンプを行う場合は、`mongodump` コマンドに `--oplog` オプションを指定して oplog（論理書き込み）を保存し、`mongorestore` コマンドの `--oplogReplay` オプションでそれを再生する必要がある。
