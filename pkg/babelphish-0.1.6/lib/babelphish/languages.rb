# a list of supported languages is available here:
# http://code.google.com/apis/ajaxlanguage/documentation/reference.html#_intro_fonje
module Babelphish
  module GoogleTranslate

    AFRIKAANS = 'af'
    ALBANIAN = 'sq'
    AMHARIC = 'am'
    ARABIC = 'ar'
    ARMENIAN = 'hy'
    AZERBAIJANI = 'az'
    BASQUE = 'eu'
    BELARUSIAN = 'be'
    BENGALI = 'bn'
    BIHARI = 'bh'
    BULGARIAN = 'bg'
    BURMESE = 'my'
    CATALAN = 'ca'
    CHEROKEE = 'chr'
    CHINESE = 'zh'
    CHINESE_SIMPLIFIED = 'zh-CN'
    CHINESE_TRADITIONAL = 'zh-TW'
    CROATIAN = 'hr'
    CZECH = 'cs'
    DANISH = 'da'
    DHIVEHI = 'dv'
    DUTCH = 'nl'  
    ENGLISH = 'en'
    ESPERANTO = 'eo'
    ESTONIAN = 'et'
    FILIPINO = 'tl'
    FINNISH = 'fi'
    FRENCH = 'fr'
    GALICIAN = 'gl'
    GEORGIAN = 'ka'
    GERMAN = 'de'
    GREEK = 'el'
    GUARANI = 'gn'
    GUJARATI = 'gu'
    HEBREW = 'iw'
    HINDI = 'hi'
    HUNGARIAN = 'hu'
    ICELANDIC = 'is'
    INDONESIAN = 'id'
    INUKTITUT = 'iu'
    ITALIAN = 'it'
    JAPANESE = 'ja'
    KANNADA = 'kn'
    KAZAKH = 'kk'
    KHMER = 'km'
    KOREAN = 'ko'
    KURDISH = 'ku'
    KYRGYZ = 'ky'
    LAOTHIAN = 'lo'
    LATVIAN = 'lv'
    LITHUANIAN = 'lt'
    MACEDONIAN = 'mk'
    MALAY = 'ms'
    MALAYALAM = 'ml'
    MALTESE = 'mt'
    MARATHI = 'mr'
    MONGOLIAN = 'mn'
    NEPALI = 'ne'
    NORWEGIAN = 'no'
    ORIYA = 'or'
    PASHTO = 'ps'
    PERSIAN = 'fa'
    POLISH = 'pl'
    PORTUGUESE = 'pt-PT'
    PUNJABI = 'pa'
    ROMANIAN = 'ro'
    RUSSIAN = 'ru'
    SANSKRIT = 'sa'
    SERBIAN = 'sr'
    SINDHI = 'sd'
    SINHALESE = 'si'
    SLOVAK = 'sk'
    SLOVENIAN = 'sl'
    SPANISH = 'es'
    SWAHILI = 'sw'
    SWEDISH = 'sv'
    TAJIK = 'tg'
    TAMIL = 'ta'
    TAGALOG = 'tl'
    TELUGU = 'te'
    THAI = 'th'
    TIBETAN = 'bo'
    TURKISH = 'tr'
    UKRAINIAN = 'uk'
    URDU = 'ur'
    UZBEK = 'uz'
    UIGHUR = 'ug'
    VIETNAMESE = 'vi'

    # all languages
    # LANGUAGES = [AFRIKAANS,ALBANIAN,AMHARIC,ARABIC,ARMENIAN,AZERBAIJANI,BASQUE,BELARUSIAN,BENGALI,BIHARI,BULGARIAN,BURMESE,CATALAN,CHEROKEE,
    #             CHINESE,CHINESE_SIMPLIFIED,CHINESE_TRADITIONAL,CROATIAN,CZECH,DANISH,DHIVEHI,DUTCH,ENGLISH,ESPERANTO,ESTONIAN,FILIPINO,FINNISH,
    #             FRENCH,GALICIAN,GEORGIAN,GERMAN,GREEK,GUARANI,GUJARATI,HEBREW,HINDI,HUNGARIAN,ICELANDIC,INDONESIAN,INUKTITUT,ITALIAN,
    #             JAPANESE,KANNADA,KAZAKH,KHMER,KOREAN,KURDISH,KYRGYZ,LAOTHIAN,LATVIAN,LITHUANIAN,MACEDONIAN,MALAY,MALAYALAM,MALTESE,MARATHI,
    #             MONGOLIAN,NEPALI,NORWEGIAN,ORIYA,PASHTO,PERSIAN,POLISH,PORTUGUESE,PUNJABI,ROMANIAN,RUSSIAN,SANSKRIT,SERBIAN,SINDHI,SINHALESE,
    #             SLOVAK,SLOVENIAN,SPANISH,SWAHILI,SWEDISH,TAJIK,TAMIL,TAGALOG,TELUGU,THAI,TIBETAN,TURKISH,UKRAINIAN,URDU,UZBEK,UIGHUR,VIETNAMESE]
    
    # Google doesn't support translations to all languages.  These are the translations available.  See:
    # http://code.google.com/apis/ajaxlanguage/documentation/#SupportedPairs
    LANGUAGES = [ALBANIAN, ARABIC, BULGARIAN, CATALAN, CHINESE, CHINESE_SIMPLIFIED,CHINESE_TRADITIONAL, CROATIAN,
                CZECH, DANISH, DUTCH, ENGLISH, ESTONIAN, FILIPINO, FINNISH, FRENCH, GALICIAN, GERMAN, GREEK, HEBREW, HINDI, HUNGARIAN,
                INDONESIAN, ITALIAN, JAPANESE, KOREAN, LATVIAN, LITHUANIAN, MALTESE, NORWEGIAN, PERSIAN, POLISH, PORTUGUESE,
                ROMANIAN, RUSSIAN, SERBIAN, SLOVAK, SLOVENIAN, SPANISH, SWEDISH, THAI, TURKISH, UKRAINIAN, VIETNAMESE]
  end
end