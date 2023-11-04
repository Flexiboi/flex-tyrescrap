local Translations = {
    error = {
        stoppedtaking = 'Stopped taking tyre..',
        notyres = 'No more tyres here..',
    },
    success = {
        placeintrunk = 'Place the tyres in your trunk',
    },
    info = {
        take = 'Take Tyre',
        takingtyres = 'Taking Tyres..',
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})