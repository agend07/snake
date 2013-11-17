class Canvas
    width: 600
    height: 400

    constructor: (background='white')->
        @canvas = document.getElementById 'myCanvas'
        @ctx = @canvas.getContext '2d'
        @background = background

    clear: ->
        @ctx.fillStyle = @background
        @ctx.fillRect 0, 0, @width, @height

    paintSnake: (snake) ->
        @ctx.fillStyle = snake.color
        @ctx.fillRect snake.x * 10, snake.y * 10, 10, 10 

    removeSnake: (snake) ->
        @ctx.fillStyle = @background
        @ctx.fillRect snake.x * 10, snake.y * 10, 10, 10 




class Snake
    constructor: (x=10, y=10, direction='up', color='green') ->
        @size = 1
        @x = x
        @y = y
        @direction = direction
        @color = color

    move: ->
        console.log @direction
        switch @direction
            when 'left' then @x--
            when 'right' then @x++
            when 'up' then @y--
            when 'down' then @y++



class Game

    constructor: ->
        @armKeyboard()
        @canvas = new Canvas
        @canvas.clear()
        @snake = new Snake

        processCallback = @process.bind(this)
        setInterval processCallback, 100


    armKeyboard: ->
        document.addEventListener 'keydown', (e) =>
            switch e.keyCode
                when 37 then @snake.direction = 'left'
                when 39 then @snake.direction = 'right'
                when 38 then @snake.direction = 'up'
                when 40 then @snake.direction = 'down'
          
    # repaint: ->
    #     # @canvas.clear()
    #     @canvas.paintSnake @snake

    process: ->
        @canvas.removeSnake @snake
        @snake.move()
        @canvas.paintSnake @snake


window.start = () ->
    game = new Game
