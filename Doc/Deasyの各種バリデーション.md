## バリデーションの種類

Deasy内で行っている入力値のバリデーションには、「jQuery Validation」を使ったバリデーションと「Mongoidのバリデータション」の二種類がある。

### (1) jQuery Validationを使ったバリデーション

* https://jqueryvalidation.org/ を使ったバリデーション
* HTML上のclass属性に「required」が入っていたら必須項目、「email」が入っていたら正しいメールアドレスであること、などのチェックを行う

以下でjQuery Validationを読み込み、

https://github.com/ddbj/sakura/blob/develop/app/assets/javascripts/application.js.coffee.erb#L6

以下のようにclass属性に「required」や「email」をセットすることで動的なバリデーションを行う（以下はcontact_personのemailの例）

https://github.com/ddbj/sakura/blob/develop/app/assets/javascripts/views/contact_person/main.js.coffee.erb#L16

### (2) Mongoidのバリデーション

Mongoidのバリデーションを使ったバリデーション。

https://docs.mongodb.com/mongoid/master/tutorials/mongoid-validation/

## jQueryValicationのカスタムバリデータ

* jQueryValidationデフォルトのバリデータ以外に、カスタムバリデータを定義することができる
* app/assets/javascripts/views/validators.js.coffee.erb
    * アルファベットのみ
        * $.addValidator "alphabets", /^[\!\#\$\%\&\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\]\^\`\{\|\}\~\w\n ]*$/i, "Only alphabets(A-Z, a-z), numbers(0-9), and symbol(@-&%..etc) are allowed."
    * 日本の電話番号
        * $.addValidator "japanphone", /^[^0].*$/i, "Please re-enter a not zero value for beginning."
    * 電話番号、FAX番号
        * $.addValidator "phone", /^[0-9\-]*$/i, "Please enter a numeric and - value."
        * $.addValidator "fax", /^[0-9\-]*$/i, "Please enter a numeric and - value."
    * quotation
        * $.addValidator "quotation", /^[^\"]*$/i, "Double quotation is not allowed for qualifier value."
    * location
        * $.addValidator "location", /^[a-zA-Z0-9\<\>\(\)\.\,\^\n]*$/i, "Only alphabets(A-Z, a-z), numbers(0-9), and some symbols(<>().,^-) are allowed."
    * year
        * $.addValidator "year", /^[0-9]{4}$/i, "Please input 4-digit number."

## バリデーション一覧

* (1) Contact person 画面
    * app/assets/javascripts/views/contact_person/main.js.coffee.erb
    * バリデーション箇所
        * email
            * 正しいemailであること(email)、必須入力(required)、アルファベットのみ（alphabets）
            * `<input name="email" class="email required alphabets" type="text" value="{{email}}" />`
        * name
            * 必須入力(required)、アルファベットのみ（alphabets）
            * `<input name="name" class="name required alphabets" type="text" value="{{name}}" />`
        * fax番号
            * 正しいFAX番号（fax）、必須入力(require)
            * `<input name="fax" class="fax required" type="text" {{#if there_is_no_fax}}disabled{{else}}value="{{fax}}"{{/if}} />`
        * phone番号
            * 必須入力(require)、正しい電話番号（phone）
            * `<input name="phone" class="phone required" type="text" value="{{phone}}" />`
        * institution
            * 必須入力(required)、アルファベットのみ（alphabets）
            * `<input name="institution" class="institution required alphabets" type="text" value="{{institution}}" />`
        * （以下省略）
* (3) Submitter 画面
    * app/assets/javascripts/views/submitters/main.js.coffee.erb
    * バリデーション箇所
        * email
            * 正しいemailアドレス（email）
            * `<input id='email_{{cid}}' name='email_{{cid}}' class="email" type="email" value='{{email}}'/>`
* (4) Reference 画面
    * app/assets/javascripts/views/references/main.js.coffee.erb
    * バリデーション箇所
        * Journal name
            * 必須入力(required)、アルファベットのみ（alphabets）
            * `<input id="journal_{{cid}}" name="journal_{{cid}}" class="journal required alphabets" type="text" value='{{journal}}' />`
        * Reference title
            * 必須入力(required)、アルファベットのみ（alphabets）
            * `<input id="title_{{cid}}" name="title_{{cid}}" class="title required alphabets" type="text" value='{{title}}' />`
        * Volume
            * 必須入力(required)、アルファベットのみ（alphabets）
            * `<input id="volume_{{cid}}" name="volume_{{cid}}" class="volume required alphabets" type="text" value='{{volume}}' />`
        * （以下省略）
* (5) Sequence 画面
    * app/models/entry.rb （17行目付近）
    * バリデーション箇所
        * シーケンス名のフォーマット
            * ```
              validates :name, format: {
                  with: /\A[\-\w]+\z/,
                  message: 'Only alphabets(A-Z, a-z), numbers(0-9), and symbol(_-) are allowed.'
              }
              ```
        * シーケンス名の長さ
            * ```
                validates :name, length: {
                     maximum: 23,
                     message: 'Length of entry name must be less than 24 characters.'
                }
                ```
* (7) Annotation 画面
    * app/assets/javascripts/views/annotations/common/edit_column_form.js.coffee.erb
        * バリデーション箇所
            * genetic code
                * アルファベットのみ（alphabets）
                * `<input name="gencode" class="gencode alphabets {{name}}" type="text" value="{{gencode}}" required />`
            * location
                * アルファベットのみ（alphabets）
                * `<input class="location alphabets" name='{{cid}}' type='text alphabets' value='{{location}}' />`
    * app/assets/javascripts/views/annotations/common/edit_row_form.js.coffee.erb
        * バリデーション箇所
            * genetic code
                * アルファベットのみ（alphabets）
                * `<input name="{{cid}}" class="gencode alphabets {{name}}" type="text" value="{{gencode}}" required />`
    * app/assets/javascripts/views/annotations/common/qualifiers/organism.js.coffee.erb
        * バリデーション箇所
            * organism名
                * `<input style="width: 30em" class="organism required quotation alphabets" />`
    * app/assets/javascripts/views/annotations/common/edit_cell_form.js.coffee.erb
        * バリデーション箇所
            * location
                * 正しいロケーションフォーマット（location）、アルファベットのみ（alphabets）
                * `<input class="location alphabets" type="text" value="{{location}}" />`


