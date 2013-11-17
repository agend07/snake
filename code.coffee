class Canvas
    width: 600
    height: 400

    constructor: (@background='white')->
        @canvas = document.getElementById 'myCanvas'
        @ctx = @canvas.getContext '2d'

    clear: ->
        @ctx.fillStyle = @background
        @ctx.fillRect 0, 0, @width, @height

    # paintSnake: (snake) ->
    #     @ctx.fillStyle = snake.color
    #     @ctx.fillRect snake.x * 10, snake.y * 10, 10, 10 

    # removeSnake: (snake) ->
    #     @ctx.fillStyle = @background
    #     @ctx.fillRect snake.x * 10, snake.y * 10, 10, 10 


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

    constructor: (@direction='left', @color='green') ->
        tail = new SnakeSegment(12, 10)
        middle = new SnakeSegment(11, 10, tail)
        @head = new SnakeSegment(10, 10, middle)
        # @extra = 0

    move: ->
        # console.log @direction
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
        segment = @head
        while segment
            segment.paint(ctx, @color)
            segment = segment.next


class Game

    constructor: ->
        @armKeyboard()
        @canvas = new Canvas
        @canvas.clear()
        @snake = new Snake
        @food = new Food(20, 20, 'orange', 10)

        processCallback = @process.bind(this)
        setInterval processCallback, 100


    armKeyboard: ->
        document.addEventListener 'keydown', (e) =>
            switch e.keyCode
                when 37 then @snake.direction = 'left'
                when 39 then @snake.direction = 'right'
                when 38 then @snake.direction = 'up'
                when 40 then @snake.direction = 'down'
          
    checkCollision: ->
        if @snake.head.x == @food.x and @snake.head.y == @food.y
            console.log 'eaten'
            @snake.extra = @food.value


    process: ->
        # @canvas.removeSnake @snake
        @snake.move()

        @canvas.clear()
        @snake.paint(@canvas.ctx)
        @food.paint(@canvas.ctx)
        @checkCollision()

window.start = () ->
    game = new Game
