# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

test = require 'tape'
{Recipe, AmorphousRecipe, PositionalRecipe, CraftingThesaurus} = require './'
Inventory = require 'inventory'
ItemPile = require 'itempile'

test 'thesaurus register', (t) ->
  thesaurus = new CraftingThesaurus()

  t.equals(thesaurus.matchesName('logOak', new ItemPile('plankOak')), false)

  thesaurus.registerName 'dye.black', 'squidInk'
  thesaurus.registerName 'dye.black', 'syntheticBlackInk'
  thesaurus.registerName 'dye.white', 'bonemeal'
  thesaurus.registerName 'dye.white', 'bleach'

  t.equals(thesaurus.matchesName('dye.black', new ItemPile('squidInk')), true)
  t.equals(thesaurus.matchesName('dye.black', new ItemPile('syntheticBlackInk')), true)
  t.equals(thesaurus.matchesName('dye.black', new ItemPile('something')), false)
  t.equals(thesaurus.matchesName('dye.white', new ItemPile('bonemeal')), true)
  t.equals(thesaurus.matchesName('dye.white', new ItemPile('bleach')), true)
  t.equals(thesaurus.matchesName('dye.white', new ItemPile('dirt')), false)

  t.end()

# convenience functions to create inventory with items of given names, one each
fillGrid = (input, names) ->
  for name, i in names
    input.set i, new ItemPile(name, 1) if name?
  return input

craftingGrid2 = (names) ->
  input = new Inventory(2, 2)
  fillGrid input, names
  return input

craftingGrid3 = (names) ->
  input = new Inventory(3, 3)
  fillGrid input, names
  return input

test 'amorphous simple recipe match', (t) ->
  r = new AmorphousRecipe ['log'], new ItemPile('plank')

  t.equals(r.matches(craftingGrid2 []), false)
  t.equals(r.matches(craftingGrid2 ['cheeselog']), false)
  t.equals(r.matches(craftingGrid2 ['log']), true)
  t.equals(r.matches(craftingGrid2 [undefined, 'log']), true)
  t.equals(r.matches(craftingGrid2 [undefined, undefined, 'log']), true)
  t.equals(r.matches(craftingGrid2 [undefined, undefined, undefined, 'log']), true)
  t.end()

test 'amorphous double ingredients', (t) ->
  r = new AmorphousRecipe ['plank', 'plank'], new ItemPile('stick')

  t.equals(r.matches(craftingGrid2 ['plank']), false)
  t.equals(r.matches(craftingGrid2 ['plank', 'plank']), true)
  t.equals(r.matches(craftingGrid2 [undefined,'plank', 'plank']), true)
  t.equals(r.matches(craftingGrid2 [undefined, undefined, 'plank', 'plank']), true)
  t.equals(r.matches(craftingGrid2 ['plank', undefined, 'plank']), true)
  t.equals(r.matches(craftingGrid2 [undefined, 'plank', undefined, 'plank']), true)
  t.equals(r.matches(craftingGrid2 [undefined, 'plank', undefined]), false)
  t.end()

test 'amorphous extraneous inputs', (t) ->
  r = new AmorphousRecipe ['plank', 'plank'], new ItemPile('stick')

  t.equals(r.matches(craftingGrid2 ['plank', 'plank', 'plank']), false)
  t.equals(r.matches(craftingGrid2 ['plank', 'plank', 'plank', 'plank']), false)
  t.end()

test 'craft thesaurus', (t) ->
  r = new AmorphousRecipe ['wood.log'], new ItemPile('plank')

  # overwrites singleton instance (sorry); recipes below will use it
  thesaurus = new CraftingThesaurus()
  thesaurus.registerName 'wood.log', 'logOak'
  thesaurus.registerName 'wood.log', 'logBirch'

  t.equals(r.matches(craftingGrid2 ['wood.log']), true)
  t.equals(r.matches(craftingGrid2 ['logOak']), true)
  t.equals(r.matches(craftingGrid2 ['logBirch']), true)
  t.equals(r.matches(craftingGrid2 ['logWhatever']), false)

  t.end()

test 'take craft empty', (t) ->
  r = new AmorphousRecipe ['log'], new ItemPile('plank')
 
  grid = craftingGrid2 ['log']
  output = r.craft(grid)
  t.equals(!!output, true)
  console.log 'output',output
  t.equals(output.item, 'plank')
  t.equals(grid.get(0), undefined)
  t.equals(grid.get(1), undefined)
  t.equals(grid.get(2), undefined)
  t.equals(grid.get(3), undefined)

  t.end()

test 'take craft leftover', (t) ->
  r = new AmorphousRecipe ['log'], new ItemPile('plank')

  grid = new Inventory(4)
  grid.set 0, new ItemPile('log', 10)

  output = r.craft(grid)
  t.equals(!!output, true)
  console.log 'output',output
  t.equals(output.item, 'plank')
  console.log 'new grid',grid
  t.equals(grid.get(0) != undefined, true)
  t.equals(grid.get(0).count, 9)
  t.equals(grid.get(0).item, 'log')
  t.equals(grid.get(1), undefined)
  t.equals(grid.get(2), undefined)
  t.equals(grid.get(3), undefined)

  t.end()

test 'positional recipe match one row', (t) ->

  r = new PositionalRecipe [['first', 'second']], new ItemPile('output', 2)

  t.equal(r.matches(craftingGrid2 ['first', 'second']), true)
  t.equal(r.matches(craftingGrid2 ['first']), false)
  t.equal(r.matches(craftingGrid2 ['second']), false)
  t.equal(r.matches(craftingGrid2 ['second', 'first']), false)
  t.equal(r.matches(craftingGrid2 [undefined, 'first']), false)
  t.equal(r.matches(craftingGrid2 [undefined, 'first', 'second']), false)

  t.end()

test 'positional recipe match two rows', (t) ->
  r = new PositionalRecipe [
      ['ingot', undefined, 'ingot'],
      [undefined, 'ingot', undefined]
    ], new ItemPile('bucket')

  t.equal(r.matches(craftingGrid3 ['ingot', undefined, 'ingot',   undefined, 'ingot']), true)
  t.equal(r.matches(craftingGrid3 ['ingot', undefined, 'ingot']), false)
  t.equal(r.matches(craftingGrid3 ['ingot']), false)

  t.end()

test 'positional recipe craft', (t) ->
  r = new PositionalRecipe [
      ['ingot', undefined, 'ingot'],
      [undefined, 'ingot', undefined]
    ], new ItemPile('bucket')

  grid = craftingGrid3 ['ingot', undefined, 'ingot',   undefined, 'ingot']
  output = r.craft(grid)
  t.equals(!!output, true)
  t.equals(output.item, 'bucket')
  console.log 'new grid',grid
  for i in [0...grid.size()]
    t.equals(grid.get(i), undefined)

  t.end()

test 'positional recipe craft leftover', (t) ->
  r = new PositionalRecipe [
      ['ingot', undefined, 'ingot'],
      [undefined, 'ingot', undefined]
    ], new ItemPile('bucket')

  grid = new Inventory(3, 3)

  grid.set 0, new ItemPile('ingot', 10)
  grid.set 2, new ItemPile('ingot', 5)
  grid.set 4, new ItemPile('ingot', 3)
 
  output = r.craft(grid)
  t.equals(!!output, true)
  t.equals(output.item, 'bucket')
  console.log 'new grid',grid

  t.equal(grid.get(0) != undefined, true)
  t.equal(grid.get(0).item, 'ingot')
  t.equal(grid.get(0).count, 10 - 1)

  t.equal(grid.get(2) != undefined, true)
  t.equal(grid.get(2).item, 'ingot')
  t.equal(grid.get(2).count, 5 - 1)

  t.equal(grid.get(4) != undefined, true)
  t.equal(grid.get(4).item, 'ingot')
  t.equal(grid.get(4).count, 3 - 1)

  for i in [0...grid.size()]
    continue if i in [0, 2, 4]
    t.equals(grid.get(i), undefined)

  t.end()

test 'positional recipe three rows', (t) ->
  r = new PositionalRecipe [
    ['wood.plank', 'wood.plank', 'wood.plank'],
    [undefined, 'stick', undefined],
    [undefined, 'stick', undefined]], new ItemPile('pickaxeWood', 1)

  grid = craftingGrid3 [
    'wood.plank', 'wood.plank', 'wood.plank',
    undefined, 'stick', undefined,
    undefined, 'stick', undefined]
  output = r.craft(grid)
  t.equals(!!output, true)
  t.equals(output.item, 'pickaxeWood')

  for i in [0...grid.size()]
    t.equals(grid.get(i), undefined)


  t.end()

test 'tighten grid', (t) ->
  checkTight = (t, grid, width, height, s) ->
    [sm, firstRow, firstColumn] = PositionalRecipe.tighten(craftingGrid3(grid))

    t.equal(sm.width, width)
    t.equal(sm.height, height)

    actual = sm.toString()
    expected = s.replace(/[, ]/g, '\t')

    t.equal(actual, expected)

  # no change (3x3->3x3)
  checkTight t, [
    'a', 'b', 'c',
    'd', 'e', 'f',
    'g', 'h', 'i'],
    3, 3, '
    1:a,1:b,1:c
    1:d,1:e,1:f
    1:g,1:h,1:i'

  # first row removed (3x3->3x2)
  checkTight t, [
    undefined, undefined, undefined,
    'd', 'e', 'f'
    'g', 'h', 'i'],
     3, 2, '
     1:d,1:e,1:f
     1:g,1:h,1:i'

  # first two (3x3->3x1)
  checkTight t, [
    undefined, undefined, undefined,
    undefined, undefined, undefined,
    'g', 'h', 'i'],
    3, 1, '
    1:g,1:h,1:i'

  # only first row, partially filled 2nd row (3x3->3x2)
  checkTight t, [
    undefined, undefined, undefined,
    undefined, undefined, 'f',
    'g', 'h', 'i'],
    3, 2, '
    ,,1:f
    1:g,1:h,1:i'

  # first row and column (3x3->2x2)
  checkTight t, [
    undefined, undefined, undefined,
    undefined, undefined, 'f',
    undefined, 'h', 'i'],
    2, 2, '
    ,1:f
    1:h,1:i'

  checkTight t, [
    'a', 'b', undefined,
    'd', undefined, undefined,
    'g', undefined, undefined],
    2, 3, '
    1:a,1:b
    1:d,
    1:g,'

  # 3x3->1x1
  checkTight t, [
    undefined, undefined, undefined,
    undefined, 'e', undefined,
    undefined, undefined, undefined],
    1, 1, '
    1:e'

  checkTight t, [
    undefined, undefined, undefined,
    undefined, undefined, undefined,
    undefined, undefined, undefined],
    1, 1, '
    '


  t.end()

test 'positional recipe size 2x2 < grid size', (t) ->
  r = new PositionalRecipe [
    [undefined, 'ingot'],
    ['ingot', undefined]], new ItemPile('shears')

  # same size
  t.equal(r.matches(craftingGrid2 [
    undefined, 'ingot',
    'ingot', undefined]), true)

  t.equal(r.matches(craftingGrid2 [
    undefined, undefined,
    'ingot', undefined]), false)
  t.equal(r.matches(craftingGrid2 [
    undefined, 'ingot',
    undefined, undefined]), false)
  t.equal(r.matches(craftingGrid2 [
    undefined, undefined,
    undefined, undefined]), false)
  t.equal(r.matches(craftingGrid2 [
    'ingot', 'ingot',
    'ingot', 'ingot']), false)


  # upper-left
  t.equal(r.matches(craftingGrid3 [
    undefined, 'ingot', undefined,
    'ingot', undefined, undefined,
    undefined, undefined, undefined]), true)

  # upper-right
  t.equal(r.matches(craftingGrid3 [
    undefined, undefined, 'ingot',
    undefined, 'ingot', undefined,
    undefined, undefined, undefined]), true)

  # lower-left
  t.equal(r.matches(craftingGrid3 [
    undefined, undefined, undefined,
    undefined, 'ingot', undefined,
    'ingot', undefined, undefined]), true)

  # lower-right
  t.equal(r.matches(craftingGrid3 [
    undefined, undefined, undefined,
    undefined, undefined, 'ingot',
    undefined, 'ingot', undefined]), true)

  t.end()

test 'positional recipe 1x3 < grid size', (t) ->
  r = new PositionalRecipe [
    ['ingot'],
    ['stick']
    ['stick']], new ItemPile('spade')

  t.equal(r.matches(craftingGrid3 [
    'ingot', undefined, undefined,
    'stick', undefined, undefined,
    'stick', undefined, undefined]), true)

  t.equal(r.matches(craftingGrid3 [
    undefined, 'ingot', undefined,
    undefined, 'stick', undefined,
    undefined, 'stick', undefined]), true)

  t.equal(r.matches(craftingGrid3 [
    undefined, undefined, 'ingot',
    undefined, undefined, 'stick',
    undefined, undefined, 'stick']), true)

  # extra items, should be excluded by larger dimensions
  t.equal(r.matches(craftingGrid3 [
    'ingot', 'ingot', undefined,
    'stick', 'ingot', undefined,
    'stick', undefined, undefined]), false)  # matches r2 below

  t.equal(r.matches(craftingGrid3 [
    'ingot', 'junk', undefined,
    'stick', undefined, undefined,
    'stick', undefined, undefined]), false)

  t.equal(r.matches(craftingGrid3 [
    'ingot', 'junk', 'morejunk',
    'stick', undefined, undefined,
    'stick', undefined, undefined]), false)

  t.equal(r.matches(craftingGrid3 [
    'junk1', 'ingot', 'junk2',
    undefined, 'stick', undefined,
    undefined, 'stick', undefined]), false)


  r2 = new PositionalRecipe [
    ['ingot', 'ingot']
    ['stick', 'ingot'],
    ['stick', undefined]], new ItemPile('axe')
  t.equal(r2.matches(craftingGrid3 [
    'ingot', 'ingot', undefined,
    'stick', 'ingot', undefined,
    'stick', undefined, undefined]), true)

  t.end()
