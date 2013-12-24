// Generated by CoffeeScript 1.6.3
(function() {
  var AmorphousRecipe, CraftingThesaurus, Inventory, ItemPile, PositionalRecipe, Recipe, craftingGrid2, craftingGrid3, fillGrid, test, _ref;

  test = require('tape');

  _ref = require('./'), Recipe = _ref.Recipe, AmorphousRecipe = _ref.AmorphousRecipe, PositionalRecipe = _ref.PositionalRecipe, CraftingThesaurus = _ref.CraftingThesaurus;

  Inventory = require('inventory');

  ItemPile = require('itempile');

  test('thesaurus register', function(t) {
    t.equals(CraftingThesaurus.matchesName('logOak', new ItemPile('plankOak')), false);
    CraftingThesaurus.registerName('blackDye', new ItemPile('squidInk'));
    CraftingThesaurus.registerName('blackDye', new ItemPile('syntheticBlackInk'));
    CraftingThesaurus.registerName('whiteDye', new ItemPile('bonemeal'));
    CraftingThesaurus.registerName('whiteDye', new ItemPile('bleach'));
    t.equals(CraftingThesaurus.matchesName('blackDye', new ItemPile('squidInk')), true);
    t.equals(CraftingThesaurus.matchesName('blackDye', new ItemPile('syntheticBlackInk')), true);
    t.equals(CraftingThesaurus.matchesName('blackDye', new ItemPile('something')), false);
    t.equals(CraftingThesaurus.matchesName('whiteDye', new ItemPile('bonemeal')), true);
    t.equals(CraftingThesaurus.matchesName('whiteDye', new ItemPile('bleach')), true);
    t.equals(CraftingThesaurus.matchesName('whiteDye', new ItemPile('dirt')), false);
    return t.end();
  });

  fillGrid = function(input, names) {
    var i, name, _i, _len;
    for (i = _i = 0, _len = names.length; _i < _len; i = ++_i) {
      name = names[i];
      if (name != null) {
        input.set(i, new ItemPile(name, 1));
      }
    }
    return input;
  };

  craftingGrid2 = function(names) {
    var input;
    input = new Inventory(2, 2);
    fillGrid(input, names);
    return input;
  };

  craftingGrid3 = function(names) {
    var input;
    input = new Inventory(3, 3);
    fillGrid(input, names);
    return input;
  };

  test('amorphous simple recipe match', function(t) {
    var r;
    r = new AmorphousRecipe(['log'], new ItemPile('plank'));
    t.equals(r.matches(craftingGrid2(['log'])), true);
    t.equals(r.matches(craftingGrid2([void 0, 'log'])), true);
    t.equals(r.matches(craftingGrid2([void 0, void 0, 'log'])), true);
    t.equals(r.matches(craftingGrid2([void 0, void 0, void 0, 'log'])), true);
    return t.end();
  });

  test('amorphous double ingredients', function(t) {
    var r;
    r = new AmorphousRecipe(['plank', 'plank'], new ItemPile('stick'));
    t.equals(r.matches(craftingGrid2(['plank'])), false);
    t.equals(r.matches(craftingGrid2(['plank', 'plank'])), true);
    t.equals(r.matches(craftingGrid2([void 0, 'plank', 'plank'])), true);
    t.equals(r.matches(craftingGrid2([void 0, void 0, 'plank', 'plank'])), true);
    return t.end();
  });

  test('amorphous extraneous inputs', function(t) {
    var r;
    r = new AmorphousRecipe(['plank', 'plank'], new ItemPile('stick'));
    t.equals(r.matches(craftingGrid2(['plank', 'plank', 'plank'])), false);
    t.equals(r.matches(craftingGrid2(['plank', 'plank', 'plank', 'plank'])), false);
    return t.end();
  });

  test('craft thesaurus', function(t) {
    var r;
    r = new AmorphousRecipe(['log'], new ItemPile('plank'));
    CraftingThesaurus.registerName('log', new ItemPile('logOak'));
    CraftingThesaurus.registerName('log', new ItemPile('logBirch'));
    t.equals(r.matches(craftingGrid2(['log'])), true);
    t.equals(r.matches(craftingGrid2(['logOak'])), true);
    t.equals(r.matches(craftingGrid2(['logBirch'])), true);
    t.equals(r.matches(craftingGrid2(['logWhatever'])), false);
    return t.end();
  });

  test('take craft empty', function(t) {
    var grid, output, r;
    r = new AmorphousRecipe(['log'], new ItemPile('plank'));
    grid = craftingGrid2(['log']);
    output = r.craft(grid);
    t.equals(!!output, true);
    console.log('output', output);
    t.equals(output.item, 'plank');
    t.equals(grid.get(0), void 0);
    t.equals(grid.get(1), void 0);
    t.equals(grid.get(2), void 0);
    t.equals(grid.get(3), void 0);
    return t.end();
  });

  test('take craft leftover', function(t) {
    var grid, output, r;
    r = new AmorphousRecipe(['log'], new ItemPile('plank'));
    grid = new Inventory(4);
    grid.set(0, new ItemPile('log', 10));
    output = r.craft(grid);
    t.equals(!!output, true);
    console.log('output', output);
    t.equals(output.item, 'plank');
    console.log('new grid', grid);
    t.equals(grid.get(0) !== void 0, true);
    t.equals(grid.get(0).count, 9);
    t.equals(grid.get(0).item, 'log');
    t.equals(grid.get(1), void 0);
    t.equals(grid.get(2), void 0);
    t.equals(grid.get(3), void 0);
    return t.end();
  });

  test('positional recipe match one row', function(t) {
    var r;
    r = new PositionalRecipe([['first', 'second']], new ItemPile('output', 2));
    t.equal(r.matches(craftingGrid2(['first', 'second'])), true);
    t.equal(r.matches(craftingGrid2(['first'])), false);
    t.equal(r.matches(craftingGrid2(['second'])), false);
    t.equal(r.matches(craftingGrid2(['second', 'first'])), false);
    t.equal(r.matches(craftingGrid2([void 0, 'first'])), false);
    t.equal(r.matches(craftingGrid2([void 0, 'first', 'second'])), false);
    return t.end();
  });

  test('positional recipe match two rows', function(t) {
    var r;
    r = new PositionalRecipe([['ingot', void 0, 'ingot'], [void 0, 'ingot', void 0]], new ItemPile('bucket'));
    t.equal(r.matches(craftingGrid3(['ingot', void 0, 'ingot', void 0, 'ingot'])), true);
    return t.end();
  });

}).call(this);
