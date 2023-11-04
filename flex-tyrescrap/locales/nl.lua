local Translations = {
    error = {
        stoppedtaking = 'Gestopt me band te pakken..',
        notyres = 'Der ligge hier geen bande meer..',
    },
    success = {
        placeintrunk = 'Plaats de band in de koffer',
    },
    info = {
        take = 'Pak banden',
        takingtyres = 'Banden aan het nemen..',
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})