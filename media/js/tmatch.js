/* constants, globals */
    var map = [];
    var cellsmap = [];
    var personsmap = [];
    var stashes = [];
    var current_stash = 0;
    var persons_sequence = 0;
    var PCLASSES = {
        "1" : "person1",
        "9" : "queen",
        };
    var CLASSES = {
        "-1": "door",
        "-2": "bug",
        "-3": "eraser",
        "-4": "matcher",
        "-5": "gdiamond",
        "-6": "bdiamond",
        "-7": "odiamond",
        };
    var TYPE_SCORE = {
        "played": {
            4: 200,
            3: 50,
            2: 10,
            1: 5,
            "-1": 500,    // Door
            "-2": 10,    // Bug
            "-3": 100,    // Key
            "-4": 250,    // Star
            },
        "comb_item": {
            1: 10,
            2: 20,
            3: 50,
            4: 100,
            5: 150,
            6: 1000,
            "-2": 100,
            "-5": 500,
            "-6": 2500,
            },
        "comb_result": {
            2: 30,
            3: 70,
            4: 150,
            5: 500,
            6: 2500,
            7: 10000,
            "-5": 750,
            "-6": 1500,
            "-7": 5000,
            },
        "destroyed": {
            7: -20000,
            6: -5000,
            5: -1000,
            4: -200,
            3: -75,
            2: -30,
            1: -5,
            "-1": 2000,
            "-2": 10,
            "-5": 500,
            "-6": 1000,
            "-7": 25000,
            },
        };
    var WIDTH = 6;
    var HEIGHT = 6;
    var CELL_WIDTH = 101;
    var CELL_HEIGHT = 81;
    var LEFT_SHIFT = 121;
    var BOTTOM_SHIFT = 10;
    var current_type = 0;
    var current = null;
    var score = 0;
    var looser = false;
    var lang_code = obtenirCodeLangueNavig();
    var step = 0;
/* Randomizers */
function randomType(randommap)
    {
    // if (!randommap) if (step === 0) return -3;
    if (typeof randommap === "undefined") randommap = false;
    var i = Math.random() * 100.0;
    if (i > 99) return 4; // Type 4
    if ((i > 98) && !randommap) return -1; // Door
    if (i > 97) return 3;  // Type 3
    if ((i > 95) && !randommap) return -4; // Star
    if ((i > 92) && !randommap) return -3; // Key
    if (i > 77) return -2; // Bug
    if (i > 52) return 2; // Type 2
    return 1; // Type 1
    }
function randomizeMap()
    {
    /*
    *
    setType(map, 0, 0, -7);
    setType(map, 2, 1, -7);
    setType(map, 0, 1, -7);
    setType(map, 1, 1, -7);
    setType(map, 3, 3, 7);
    setType(map, 3, 1, 7);
    setType(map, 0, 2, 7);
    setType(map, 1, 2, 6);
    setType(map, 2, 2, 6);
    addPerson(3,3,9);
    addPerson(0,2,9);
    return;
    /*
    */
    var percent = 0.7;
    var whereToPutQueen = null;
    for (var x = 0; x < WIDTH; x ++)
        {
        for (var y = 0; y < HEIGHT; y ++)
            {
            if (Math.random() > percent)
                {
                rt = randomType(true);
                if ((rt > 0) && (whereToPutQueen === null)) whereToPutQueen = [x,y];
                setType(map, x, y, rt);
                }
            }
        }
    if (whereToPutQueen === null)
        {
        whereToPutQueen = [int(Math.random() * WIDTH), int(Math.random() * HEIGHT)];
        setType(map, whereToPutQueen[0], whereToPutQueen[1], 1);
        }
    addPerson(whereToPutQueen[0], whereToPutQueen[1], 9);
    }
/* Helpers */
function setClass(node, t)
    {
    dojo.removeClass(node);
    dojo.addClass(node, "mapcell");
    if ((typeof t === "undefined") || (t === 0))
        {
        dojo.addClass(node, "empty");
        }
    else if (t > 0)
        {
        dojo.addClass(node, "type_" + t);
        }
    else
        {
        dojo.addClass(node, CLASSES[t]);
        }
    }
function setType(map, x, y, t)
    {
    if (typeof map[x] === "undefined") map[x] = [];
    if (typeof cellsmap[x] === "undefined") cellsmap[x] = [];
    map[x][y] = t;
    setClass(cellsmap[x][y], t);
    }
function coordsToI(x, y)
    {
    return y*WIDTH + x;
    }
function personCoordToDomCoord(x, y)
    {
    return [(CELL_WIDTH*x+LEFT_SHIFT+30), (CELL_HEIGHT*(HEIGHT-y-1)+BOTTOM_SHIFT+50)];
    }
function personPresent(x, y)
    {
    for (var i = 0; i < personsmap.length ; i++)
        {
        p = personsmap[i];
        if ((p['x'] == x) && (p['y'] == y)) return true;
        }
    return false;
    }
function findEquiv(map, t, x, y, seen, ignore)
    {
    if ((typeof ignore === "undefined") && (map[x][y] !== t)) return [];
    var result = [[x,y]]
    if (typeof seen === "undefined") seen = [];
    seen.push(coordsToI(x,y));
    if ((dojo.indexOf(seen, coordsToI(x-1,y)) === -1) && (x > 0) && (map[x-1][y] === t))
        result = result.concat(findEquiv(map, t, x-1, y, seen));
    if ((dojo.indexOf(seen, coordsToI(x+1,y)) === -1) && (x < WIDTH-1) && (map[x+1][y] === t))
        result = result.concat(findEquiv(map, t, x+1, y, seen));
    if ((dojo.indexOf(seen, coordsToI(x,y-1)) === -1) && (y > 0) && (map[x][y-1] === t))
        result = result.concat(findEquiv(map, t, x, y-1, seen));
    if ((dojo.indexOf(seen, coordsToI(x,y+1)) === -1) && (y < HEIGHT-1) && (map[x][y+1] === t))
        result = result.concat(findEquiv(map, t, x, y+1, seen));
    return result;
    }
function getNeighboor(map, x, y, diagonals)
    {
    if (typeof diagonals === "undefined") diagonals = false;
    var neighboor = [];
    if (x>0)                       neighboor.push([x-1, y,   map[x-1][y]]);
    if (x<WIDTH-1)                 neighboor.push([x+1, y,   map[x+1][y]]);
    if (y>0)                       neighboor.push([x,   y-1, map[x]  [y-1]]);
    if (y<HEIGHT-1)                neighboor.push([x,   y+1, map[x]  [y+1]]);

    /* diagonals */
    if (diagonals)
        {
        if ((x>0) && (y>0))              neighboor.push([x-1, y-1, map[x-1][y-1]]);
        if ((x>0) && (y<HEIGHT-1))       neighboor.push([x-1, y+1, map[x-1][y+1]]);
        if ((x<WIDTH-1) && (y>0))        neighboor.push([x+1, y-1, map[x+1][y-1]]);
        if ((x<WIDTH-1) && (y<HEIGHT-1)) neighboor.push([x+1, y+1, map[x+1][y+1]]);
        }
    return neighboor;
    }
function addPerson(x, y, t)
    {
    domcoords = personCoordToDomCoord(x,y);
    my_id = persons_sequence;
    persons_sequence += 1;
    domnode= dojo.create("div", {"style":"bottom:"+domcoords[1]+";left:"+domcoords[0]+";",innerHTML:"&nbsp;","pidx":persons_sequence}, dojo.byId("personscontainer"));
    tooltipnode= dojo.create("div", {}, domnode);
    p = {
        type: t,
        domnode: domnode,
        tooltipnode: tooltipnode,
        x:x,
        y:y,
        idx:persons_sequence
        };
    dojo.addClass(p["domnode"], PCLASSES[t]);
    dojo.addClass(p["tooltipnode"], "persontt");
    dojo.connect(p["domnode"], "onclick", function(evt)
        {
        idx = parseInt(dojo.attr(this, "pidx"));
        if (isNaN(idx)) return;
        current_stash = idx;
        setClass(stash, stashes[current_stash]);
        });
    personsmap.push(p);
    }
function findPerson(idx)
    {
    for (var i = 0; i < personsmap.length ; i ++)
        {
        p = personsmap[i];
        if (p['idx'] == idx) return p;
        }
    }
function loosePerson(p)
    {
    // Change the current stash to the first "other person"
    var found = false;
    var my_index_in_map = null;
    for (var i = 0; i < personsmap.length ; i ++)
        {
        op = personsmap[i];
        if (op['idx'] === p['idx'])
            {// that's me
            my_index_in_map = i;
            }
        else
            {
            current_stash = op['idx'];
            setClass(stash, stashes[current_stash]);
            found = true;
            }
        }
    if (my_index_in_map !== null)
        {
        p['domnode'].parentNode.removeChild(p['domnode']);
        personsmap.splice(my_index_in_map, 1);
        }
    if (!found) // I was the last one ?
        {
        looser = true;
        var msg = dojo.create("div", {innerHTML: "Looser"}, "container");
        dojo.addClass(msg, "message");
        }
    }

/* Map functions */
function makeMap()
    {
    for (var x = 0; x < WIDTH; x++)
        {
        for (var y = 0; y < HEIGHT; y++)
            {
            /* map */
            if (typeof map[x] === "undefined") map[x] = [];
            map[x][y] = 0;
            /* cellsmap */
            if (typeof cellsmap[x] === "undefined") cellsmap[x] = [];
            cellsmap[x][y] = dojo.create("div", {"tmatchx":x,"tmatchy":y,"style":"bottom:"+(CELL_HEIGHT*(HEIGHT-y-1)+BOTTOM_SHIFT)+";left:"+(CELL_WIDTH*x+LEFT_SHIFT)+";",innerHTML:"&nbsp;"}, dojo.byId("playzone"));
            setClass(cellsmap[x][y], 0);
            }
        }
    }

/* Game turn functions */
function checkComb(map, t, x, y)
    {
    var comb = findEquiv(map, t, x, y);
    var newtype = t + 1;
    if (t < -4) newtype = t - 1;
    if ((newtype <= -8) || (newtype >= 8))
        {
        return;
        }
    if (comb.length > 2)
        {
        for (var i = 0; i < comb.length; i ++)
            {
            u = comb[i][0]; v = comb[i][1];
            if (typeof TYPE_SCORE['comb_item'][t] !== undefined)
                {
                score += TYPE_SCORE['comb_item'][t];
                }
            setType(map, u, v, 0);
            }
        setType(map, x, y, newtype);
        checkComb(map, newtype, x, y);
        if (typeof TYPE_SCORE['comb_result'][t+1] !== undefined)
            {
            score += TYPE_SCORE['comb_result'][t+1];
            }
        if (newtype > 5) addPerson(x, y, 1);
        }
    }
function matchAll(map, x, y)
    {
    result = [];
    var possible_types = [];
    var t = 0;
    var equiv = [];
    if (x>0) possible_types.push(map[x-1][y]);
    if (x<WIDTH-1) possible_types.push(map[x+1][y]);
    if (y>0) possible_types.push(map[x][y-1]);
    if (y<HEIGHT-1) possible_types.push(map[x][y+1]);
    possible_types = sort_unique(possible_types);
    for(var i = 0; i < possible_types.length ; i++)
        {
        t = possible_types[i];
        if (((t < 1) && (t > -5)) || (t < -6) || (t > 6)) continue; // we can match regular blocks and tombstones
        equiv = findEquiv(map, t, x, y, [], true);
        if (equiv.length > 2)
            {
            map[x][y] = t;
            checkComb(map, t, x, y);
            return true;
            }
        }
    return false;
    }
function bugMove(map, x, y)
    {
    var nei = getNeighboor(map, x, y);
    nei.sort(function() { return (Math.round(Math.random())-0.5); });
    for (var i = 0; i < nei.length; i++)
        {
        n = nei[i];
        if (n[2] === 0)
            {
            setType(map, n[0], n[1], map[x][y]);
            setType(map, x, y, 0);
            break;
            }
        }
    }
function personMoveTo(p, x, y)
    {
    p['x'] = x;
    p['y'] = y;
    domcoords = personCoordToDomCoord(x,y);
    dojo.style(p['domnode'], "bottom", domcoords[1]);
    dojo.style(p['domnode'], "left", domcoords[0]);
    }
function checkLooseCondition()
    {
    for (var x = 0; x < WIDTH; x ++)
        {
        for (var y = 0; y < HEIGHT ; y ++)
            {
            if (map[x][y] === 0)
                {
                return false;
                }
            }
        }
    return true;
    }
function checkBugKill(map, x, y)
    {
    other_bugs = findEquiv(map, -2, x, y);
    for (var i = 0; i < other_bugs.length; i ++)
        {
        ob = other_bugs[i];
        nei = getNeighboor(map, ob[0], ob[1]);
        for (var j = 0; j < nei.length; j ++)
            {
            n = nei[j];
            if (map[n[0]][n[1]] == 0)
                {
                return 0;
                }
            }
        }
    for (var i = 0; i < other_bugs.length; i ++)
        {
        ob = other_bugs[i];
        if (typeof TYPE_SCORE['comb_result'][-5] !== undefined)
            {
            score += killcount * TYPE_SCORE['comb_result'][-5];
            }
        setType(map, ob[0], ob[1], -5);
        }
    checkComb(map, -5, x, y, map[2][0],map[2][1]);
    return other_bugs.length;
    }
function doPersonStep(p)
    {
    var nei = getNeighboor(map, p['x'],p['y'],true);
    var moveOrNot = (Math.random() > 0.5);
    var onWater = (map[p['x']][p['y']] === 0);
    var couldMove = false;
    if ((moveOrNot) || (onWater)) // always move if on water
        {
        nei.sort(function() { return (Math.round(Math.random())-0.5); });
        for (var i = 0; i < nei.length; i++)
            {
            n = nei[i];
            if ((n[2] > 0) && (!personPresent(n[0], n[1])))
                {
                personMoveTo(p, n[0], n[1]);
                couldMove = true;
                break;
                }
            }
        }
    if ((!couldMove) && (onWater)) // He couldn't move
        {
        loosePerson(p);
        }
    }
function doOneStep(changetype)
    {
    if (typeof changetype === "undefined") changetype = true;
    if (changetype)
        {
        current_type = randomType();
        setClass(current, current_type);
        }
    var bugs = [];
    for (var x = 0; x < WIDTH; x ++)
        {
        for (var y = 0; y < HEIGHT ; y ++)
            {
            if (map[x][y] === -2)
                {
                bugs.push([x,y]);
                }
            }
        }
    for (var i = 0; i < bugs.length; i++)
        {
        b = bugs[i];
        // We check again the type in case this bug was destroyed by another one
        if (map[b[0]][b[1]] === -2)
            {
            killcount = checkBugKill(map, b[0], b[1]);
            if (killcount > 0)
                {
                if (typeof TYPE_SCORE['comb_item'][-2] !== undefined)
                    {
                    score += killcount * TYPE_SCORE['comb_item'][-2];
                    }
                }
            else
                {
                bugMove(map, b[0], b[1]);
                }
            }
        }
    for (var i = 0; i < personsmap.length; i++)
        {
        p = personsmap[i];
        if (p["type"] !== 0) doPersonStep(p);
        }
    if (checkLooseCondition())
        {
        looser = true;
        var msg = dojo.create("div", {innerHTML: "Looser"}, "container");
        dojo.addClass(msg, "message");
        }
    dojo.attr("score", "innerHTML", score);
    step += 1;
    }

/* Main */
dojo.addOnLoad(function()
    {
    //var map = [];
    current_type = randomType();
    var container = dojo.create("div", {id: "container"}, dojo.body());
    current = dojo.create("div", {id: "current", innerHTML:(lang_code === "fr" ? "En cours" : "Current")}, container);
    dojo.create("div", {id: "score", innerHTML: score}, container);
    setClass(current, current_type);
    var stash = dojo.create("div", {id: "stash", innerHTML: (lang_code === "fr" ? "Réserve" : "Stash")}, container);
    dojo.connect(stash, "onclick", function(evt)
        {
        if (looser) return;
        var old_stash = stashes[current_stash];
        var old_person = findPerson(current_stash);
        var stashed_item = current_type;
        if (typeof old_person === "undefined") old_person = findPerson(1);
        stashes[current_stash] = stashed_item;
        setClass(stash, stashes[current_stash]);
        if ((typeof old_stash !== "undefined") && (old_stash !== 0))
            {
            current_type = old_stash;
            setClass(current, current_type);
            }
        else
            {
            current_type = randomType();
            setClass(current, current_type);
            }
        setClass(old_person['tooltipnode'], stashed_item);
        });
    var playzone = dojo.create("div", {id: "playzone"}, container);
    dojo.create("div", {id: "personscontainer"}, container);
    makeMap();
    randomizeMap();
    for (var x = 0; x < WIDTH ; x ++)
        {
        for (var y = 0; y < HEIGHT; y ++)
            {
            dojo.connect(cellsmap[x][y], "onclick", function(evt)
                {
                if (looser) return;
                x = parseInt(dojo.attr(this, "tmatchx"));
                y = parseInt(dojo.attr(this, "tmatchy"));
                celltype = map[x][y];
                if ((evt.offsetY < 50) && (y > 0))
                    {
                    y-=1;
                    celltype = map[x][y];
                    }
                if ((current_type === -3) && (celltype !== 0)) // eraser
                    {
                    if (typeof TYPE_SCORE['played'][current_type] !== undefined)
                        {
                        score += TYPE_SCORE['played'][current_type];
                        }
                    if (typeof TYPE_SCORE['destroyed'][celltype] !== undefined)
                        {
                        score += TYPE_SCORE['destroyed'][celltype];
                        }
                    setType(map, x, y, 0);
                    doOneStep();
                    }
                else if (celltype === 0)
                    {
                    if (typeof TYPE_SCORE['played'][current_type] !== undefined)
                        {
                        score += TYPE_SCORE['played'][current_type];
                        }
                    if (current_type > 0)
                        {
                        setType(map, x, y, current_type);
                        checkComb(map, current_type, x, y);
                        doOneStep();
                        }
                    else if (current_type === -4) // matcher
                        {
                        if (matchAll(map, x, y))
                            {
                            doOneStep();
                            }
                        }
                    else if ((current_type === -1) || (current_type === -2))
                        {
                        setType(map, x, y, current_type);
                        doOneStep();
                        }
                    }
                });
            }
        }
    });
