width = 60
height = 40

backgroundColor = 'white'
headColor = 'red'
snakeColor = 'green'
foodColor = 'orange'


randomInt = (lower, upper) ->
    start = Math.random()
    Math.floor(start * (upper - lower + 1) + lower)


class Board
    constructor: ->
        @array = []

        for _ in [0...height]
            row = []
            for _ in [0...width]
                row.push 0

            @array.push row

    clear: ->
        for y in [0...height]
            for x in [0...width]
                @set x, y, 0

    get: (x, y) ->
        return @array[y][x]

    set: (x, y, value) ->
        @array[y][x] = value


class Canvas
    width: width * 10
    height: height * 10

    constructor: ->
        @canvas = document.getElementById 'myCanvas'
        @ctx = @canvas.getContext '2d'

    clear: ->
        @ctx.fillStyle = backgroundColor
        @ctx.fillRect 0, 0, @width, @height

    paint: (board) ->
        for y in [0...height]
            for x in [0...width]
                switch board.get x, y
                    when 1 then @ctx.fillStyle = snakeColor
                    when 2 then @ctx.fillStyle = headColor
                    when 3 then @ctx.fillStyle = foodColor
                    else @ctx.fillStyle = backgroundColor

                @ctx.fillRect x * 10, y * 10, 10, 10 


class Point
    constructor: (@x, @y) ->


class Food
    constructor: (@x, @y, @value=3) ->

    project: (board) ->
        board.set @x, @y, 3


class SnakeSegment
    constructor: (@x, @y, @next=null) ->


class Snake
    constructor: (@direction='right') ->
        @head = new SnakeSegment(10, 10)
        segment = @head
        for i in [0..3]
            newSegment = new SnakeSegment(10, segment.y + 1)
            segment.next = newSegment
            segment = newSegment

    move: ->
        newHead = switch @direction
            when 'left' then new SnakeSegment(@head.x-1, @head.y, @head)
            when 'right' then new SnakeSegment(@head.x+1, @head.y, @head)
            when 'up' then new SnakeSegment(@head.x, @head.y-1, @head)
            when 'down' then new SnakeSegment(@head.x, @head.y+1, @head)

        @head = newHead

        if @extra > 0   # if food was eaten and there are new segments I'm done for this cycle
            @extra--
            return

        # remove last segment 
        segment = @head
        while segment
            if segment.next and not segment.next.next
                segment.next = null
                break
            segment = segment.next

    project: (board) ->
        board.set @head.x, @head.y, 2

        segment = @head.next
        while segment
            board.set segment.x, segment.y, 1
            segment = segment.next

  
class SnakeBrain
    checkPointIsOccupied: (point) ->
        if point.x < 0 or point.x >= width or point.y < 0 or point.y >= height  # outside of board
            return true

        @board.get(point.x, point.y) == 1

    getDistanceToFood: (point) ->
        dX = (point.x - @food.x)
        dY = (point.y - @food.y)
        dX * dX + dY * dY

    countNeighbours: (point) ->
        result = 0
        if @checkPointIsOccupied new Point(point.x, point.y+1) then result++
        if @checkPointIsOccupied new Point(point.x, point.y-1) then result++
        if @checkPointIsOccupied new Point(point.x+1, point.y) then result++
        if @checkPointIsOccupied new Point(point.x-1, point.y) then result++
        result

    think: (@board, @snake, @food) ->
        x = @snake.head.x
        y = @snake.head.y

        directions = 
            up: new Point(x, y-1)
            down: new Point(x, y+1)
            left: new Point(x-1, y)
            right: new Point(x+1, y)

        # if some direction is illegal it will be deleted - like snake body or outside the board
        for own key, value of directions
            if @checkPointIsOccupied value
                delete directions[key]

        # filter directions instead of distances
        # for own key, value of directions
        #     if @checkForClosedSpace value
        #         delete directions[key]

        distances = []

        for own key, value of directions
            distance = @getDistanceToFood(value)
            neighbours = @countNeighbours(value)
            if neighbours < 3
                distances.push([key, distance])

        distances.sort (a, b) ->
            a[1] - b[1]

        if distances.length > 0
            @snake.direction = distances[0][0]



class Game
    constructor: ->
        # @armKeyboard()
        @canvas = new Canvas
        @board = new Board

        @snake = new Snake
        @snake.project @board

        @food = @addFood @board
        @food.project @board

        @brain = new SnakeBrain @board, @snake, @food

        @canvas.paint @board

        processCallback = @mainLoop.bind(this)
        @processing = setInterval processCallback, 30


    mainLoop: ->
        @brain.think(@board, @snake, @food)

        if @checkCollision @board
            @snake.move()
            return
        else
            @snake.move()

        @checkFoodEaten @board

        @board.clear()
        @snake.project @board
        @food.project @board

        @canvas.paint @board

    armKeyboard: ->
        document.addEventListener 'keydown', (e) =>
            if e.keyCode == 37 and @snake.direction != 'right' then @snake.direction = 'left'
            if e.keyCode == 39 and @snake.direction != 'left' then @snake.direction = 'right'
            if e.keyCode == 38 and @snake.direction != 'down' then @snake.direction = 'up'
            if e.keyCode == 40 and @snake.direction != 'up' then @snake.direction = 'down'
          
    checkCollision: (board) ->
        nextHead = switch @snake.direction
            when 'up' then new Point(@snake.head.x, @snake.head.y-1)
            when 'down' then new Point(@snake.head.x, @snake.head.y+1)
            when 'left' then new Point(@snake.head.x-1, @snake.head.y)
            when 'right' then new Point(@snake.head.x+1, @snake.head.y)

        # check I'm inside of the board
        if nextHead.x < 0 or nextHead.x >= width or nextHead.y < 0 or nextHead.y >= height
            @gameOver()
            return true

        # check head didn't hit the tail
        if board.get(nextHead.x, nextHead.y) == 1
            @gameOver()
            return true

        return false

    checkFoodEaten: (board) -> 
        if @snake.head.x == @food.x and @snake.head.y == @food.y
            console.log 'eaten'
            @snake.extra = @food.value
            @food = @addFood board

    # draw random position on board - but not occupied by any snake segment
    addFood: (board) ->
        loop
            x = randomInt(0, width-1)
            y = randomInt(0, height-1)

            if board.get(x, y) == 0
                return new Food(x, y, 3)

    gameOver: () ->
        clearInterval @processing
        document.getElementsByTagName('body')[0].className += ' tragedy'


    # checkFourPointsAround: (point) ->
        # ta funkcja musi wiedzieć co jest już zajęte przez zamalowane punkty, nie tylko węża
        # jak to zrobić - pierwsza myśl albo rekurencja??? - albo muszę pamiętać z której strony powstał punkt?
        # albo mieć listę punktów i sprawdzać węża, border i te punkty - może tak byłoby najłatwiej

    # checkForClosedSpace: (direction) ->
        # console.log direction
        # if there is more space then snakes length it might be allright

        # i dont have to worry about food, only snake body, and borders

        # it would help if i paint the closed space for some color

        # i know where the snake is, know where the borders are, so i start with the head and start counting
        # for example start left - if it works - it is empty - add this point to list
        # from this point try to paint another 4 points around
        # if it works i have four - not gonna happen but 3 or less new points
        # and as many this new points i have to try - and as long as i get new points
        
        # need to have the board with chosen direction - so like would it look like if snake took this path
        # and see 


window.start = () ->
    game = new Game
