D-easy を稼働させる主たるサービスである MongoDB および Unicorn の起動、停止、再起動の手順。

以下、環境構築手順書に準じて動作環境が構築されているものとし、プロダクション環境 (コンテナイメージ名 `deasy-production.simg`、インスタンス名 `MongoProduction` および `UnicornProduction`) での操作手順を示す。ステージング環境で行う場合は適宜読み替えて対応されたし。

## MongoDB

### 起動

```
$ cd ~/singularity/deasy
$ ./start_mongo.sh production
````

インスタンス名 `MongoProduction` のコンテナインスタンスが開始され、レプリカセット `deasy`、ポート番号 57010, 57011, 57012 の MongoDB が起動する。

レプリケーションの構成は一度行われていれば再度実行する必要はない。（構成の手順については環境構築手順書を参照のこと。）

### 停止

```
$ singularity instance.stop MongoProduction
```

コンテナインスタンス上の全ての MongoDB プロセスが終了し、インスタンスも停止する。

### 再起動

上記の停止、起動を順に実行する。

## Unicorn

### 起動

```
$ cd ~/singularity/deasy
$ ./start_unicorn.sh production
```

インスタンス名 `UnicornProduction` のコンテナインスタンスが開始され、ポート番号 3000 の Unicorn が起動する。


### 停止

```
$ singularity instance.stop UnicornProduction
```

コンテナインスタンス上の全ての Unicorn プロセスが終了し、インスタンスも停止する。


### 再起動

Unicorn プロセスにシグナルを送信してプロセスを再起動させることが可能。（上記の停止、起動を順に実行してもよい。）

```
$ singularity run instance://UnicornProduction unicorn_restart
```

