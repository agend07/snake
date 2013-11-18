class Canvas
    width: 600
    height: 400

    constructor: (@background='white')->
        @canvas = document.getElementById 'myCanvas'
        @ctx = @canvas.getContext '2d'

    clear: ->
        @ctx.fillStyle = @background
        @ctx.fillRect 0, 0, @width, @height

class Food
    constructor: (@x, @y, @color='orange', @value=3) ->

    paint: (ctx) ->
        ctx.fillStyle = @color
        ctx.fillRect @x * 10, @y * 10, 10, 10 


class SnakeSegment
    constructor: (@x, @y, @next=null) ->

    paint: (ctx, color) ->
        ctx.fillStyle = color
        ctx.fillRect @x * 10, @y * 10, 10, 10 


class Snake

    constructor: (@direction='left', @color='green', @headColor='red') ->
        tail = new SnakeSegment(12, 10)
        middle = new SnakeSegment(11, 10, tail)
        @head = new SnakeSegment(10, 10, middle)

    move: ->
        newHead = switch @direction
            when 'left' then new SnakeSegment(@head.x-1, @head.y, @head)
            when 'right' then new SnakeSegment(@head.x+1, @head.y, @head)
            when 'up' then new SnakeSegment(@head.x, @head.y-1, @head)
            when 'down' then new SnakeSegment(@head.x, @head.y+1, @head)

        @head = newHead

        if @extra > 0
            @extra--
            return

        segment = @head
        while segment
            if segment.next and not segment.next.next
                segment.next = null
                break
            segment = segment.next

    paint: (ctx) ->
        @head.paint(ctx, @headColor)
        segment = @head.next
        while segment
            segment.paint(ctx, @color)
            segment = segment.next

    checkPosition: (x, y, head=true) ->
        # if snake takes this position return true

        if head
            segment = @head
        else
            segment = @head.next

        while segment
            if segment.x == x and segment.y == y
                return true
            segment = segment.next
        return false


class Game
    constructor: ->
        @armKeyboard()
        @canvas = new Canvas
        @canvas.clear()
        @snake = new Snake
        @food = @addFood()

        processCallback = @process.bind(this)
        @processing = setInterval processCallback, 100

    randomInt: (lower, upper) ->
        start = Math.random()
        Math.floor(start * (upper - lower + 1) + lower)

    armKeyboard: ->
        document.addEventListener 'keydown', (e) =>
            if e.keyCode == 37 and @snake.direction != 'right' then @snake.direction = 'left'
            if e.keyCode == 39 and @snake.direction != 'left' then @snake.direction = 'right'
            if e.keyCode == 38 and @snake.direction != 'down' then @snake.direction = 'up'
            if e.keyCode == 40 and @snake.direction != 'up' then @snake.direction = 'down'
          
    checkCollision: ->
        if @snake.head.x == @food.x and @snake.head.y == @food.y
            console.log 'eaten'
            @snake.extra = @food.value
            @food = @addFood()

        if @snake.checkPosition(@snake.head.x, @snake.head.y, false)
            @gameOver()
            return true

        if @snake.head.x < 0 or @snake.head.x > 59 or @snake.head.y < 0 or @snake.head.y > 39
            @gameOver()
            return true

        false 


    addFood: ->
        # board is 60 x 40 - find random position - but not occupied by snake segment
        loop
            x = @randomInt(0, 59)
            y = @randomInt(0, 39)

            # check if x,y is available
            if not @snake.checkPosition(x, y)
                break

        new Food(x, y, 'orange', 10)

    gameOver: () ->
        clearInterval @processing
        document.getElementsByTagName('body')[0].className += ' tragedy'

    process: ->
        @snake.move()
        if @checkCollision()
            return

        @canvas.clear()
        @snake.paint(@canvas.ctx)
        @food.paint(@canvas.ctx)
        console.log @snake.head.x, @snake.head.y 

window.start = () ->
    game = new Game
