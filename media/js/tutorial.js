var Tutorial = {

    enabled: true,
    lang: 'en',
    tutorials: {
        GAME_START: {
            text: {
                'en': "Welcome in Triple Match. This game is about placing tiles and combining them into better ones. Let's begin by looking at the UI. In the top-left corner is your score. Below are save/load buttons that allow you to... save and load your game. Below the save/load buttons there's a number displayed, it's the current 'z' coordinate (more on that later). Then you have the 'current' zone wich displays the next tile you'll have to place. Finally, the 'stash' zone that will be explained later. Now place the current tile on the game.",
                'fr': "Bienvenue dans Triple Match. Dans ce jeu, il s'agit de placer des tuiles et de les combiner en de 'meilleures' tuiles. Commençons par regarder l'interface. Dans le coin en haut, à gauche, s'affiche votre score. En dessous, les boutons sauver/charger qui permettent de sauvegarder ou de recharger une partie. Ensuite apparaît la valeur de 'z' en cours (on en dira plus là dessus plus tard). Juste dessous, la zone 'En cours' qui affiche la prochaine tuile à poser et pour finir la 'réserve' qui sera expliquée bientôt. Maintenant, pour commencer, placez la première tuile sur la zone de jeu.",
                },
            displayed: false,
            },
        FIRST_TILE_PLACED: {
            text: {
                'en': "Great, you've placed your first tile. You have to be warned, if the game board is filled with tiles and there is no water left, you lose. Ok. So, this game is about combining tiles so go on, place tiles until you combine three identical tiles side to side.",
                'fr': "Bien, vous avez placé votre première tuile. Attention, si la zone de jeu est pleine et qu'il ne reste plus d'eau, vous perdez. Bon, ce jeu consiste a combiner des tuiles identiques alors allons-y, placez des tuiles jusqu'à combiner trois tuiles identiques côte à côte.",
                },
            displayed: false,
            },
        FIRST_COMB_MADE: {
            text: {
                'en': "Nice, now you see the mechanic of the game. Place tiles, when three identical tiles are side by side, they disappear and a brand new one replaces the last tile you placed. This new tile is of one 'level' higher than the tiles that made the combination.",
                'fr': "Super, vous connaissez maintenant le mécanisme du jeu. Placez des tuiles, lorsque trois tuiles identiques se touchent, elles disparaissent et une nouvelle tuile remplace la dernière que vous avez placé. Cette nouvelle tuile est d'un 'niveau' supérieur aux tuiles qui ont servi pour la combinaison.",
        },

    init: function(lang)
        {
        this.lang = lang;
        var user_disabled_tuto = localStorage.getItem('TMatch_tuto_disabled');
        var tuto_item_displayed = localStorage.getItem('TMatch_tuto_item_displayed');
        if (tuto_item_displayed === null) tuto_item_displayed = '{}';
        tuto_item_displayed = dojo.fromJson(tuto_item_displayed);
        this.enabled = (user_disabled_tuto === null ? !user_disabled_tuto : true);
        for(var k in this.tutorials)
            {
            if (tuto_item_displayed[k]) this.tutorials[k].displayed = true;
            }
        },

    saveStatus: function()
        {
        var tuto_item_displayed = {};
        for(var k in this.tutorials)
            {
            if (this.tutorials[k].displayed) tuto_item_displayed[k] = true;
            }
        localStorage.setItem('TMatch_tuto_item_displayed', dojo.toJson(tuto_item_displayed));
        },

    showTutorial: function(tuto_key)
        {
        var tuto = this.tutorials[tuto_key];
        if (!tuto) return;
        if (tuto.displayed) return;
        console.log(tuto.text[this.lang]);
        this.tutorials[tuto_key].displayed = true;
        // TODO : this.saveStatus();
        },

    };
