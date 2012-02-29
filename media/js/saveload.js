var TMatchSaveLoader = {

    save: function(savename, map, current_type, score, personsmap, current_stash, stashes)
        {
        var object_to_save = {
            map: dojo.clone(map),
            current_type: current_type,
            score: score,
            personsmap: [],
            current_stash: current_stash,
            stashes: dojo.clone(stashes),
            };
        for (var i = 0; i < personsmap.length; i ++)
            {
            var p = personsmap[i];
            var serializable_p = {
                type: p.type,
                x: p.x,
                y: p.y,
                z: p.z,
                };
            object_to_save['personsmap'].push(serializable_p);
            }
        localStorage.setItem(savename, dojo.toJson(object_to_save));
        },

    load: function(savename)
        {
        var json_data = localStorage.getItem(savename);
        if (json_data === null) return null;
        return dojo.fromJson(json_data);
        },

    _checkAvailability: function()
        {
        if (localStorage)
            {
            return true;
            }
        else
            {
            return false;
            }
        }
    };
