Precis = require './index'
{ucs2} = require 'punycode'

module.exports = class PrecisEnforcer

    constructor: (
        @preparer
        @propertyReader
        @widthMapper
        @normalizer
        @directionalityValidator
    ) ->

    enforce: (profile, string) ->
        codepoints = @preparer.prepare profile, string

        profile.map codepoints, @propertyReader if profile.map?

        if profile.widthMapping is Precis.WIDTH_MAPPING.EAW
            @widthMapper.map codepoints

        if profile.caseMapping is Precis.CASE_MAPPING.LOWERCASE
            codepoints = ucs2.decode ucs2.encode(codepoints).toLowerCase()

        switch profile.normalization
            when Precis.NORMALIZATION.C
                codepoints = ucs2.decode @normalizer.nfc ucs2.encode codepoints
            when Precis.NORMALIZATION.D
                codepoints = ucs2.decode @normalizer.nfd ucs2.encode codepoints
            when Precis.NORMALIZATION.KC
                codepoints = ucs2.decode @normalizer.nfkc ucs2.encode codepoints
            when Precis.NORMALIZATION.KD
                codepoints = ucs2.decode @normalizer.nfkd ucs2.encode codepoints

        if profile.directionality is Precis.DIRECTIONALITY.BIDI
            @directionalityValidator.validate codepoints

        profile.validate codepoints if profile.validate?

        ucs2.encode codepoints
