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
        @array[y][x]

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
        # console.log 'food at', @x, @y

    # distance: (point) ->
    #     deltaX = (@x - point.x)
    #     deltaY = (@y - point.y)
    #     deltaX * deltaX + deltaY * deltaY


class SnakeSegment
    constructor: (@x, @y, @next=null) ->


class Snake
    constructor: (@direction='right') ->
        tail = new SnakeSegment(10, 12)
        middle = new SnakeSegment(10, 11, tail)
        @head = new SnakeSegment(10, 10, middle)

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

    # bitHimself: (x, y, head=true) ->
    #     # if snake takes this position return true

    #     if head
    #         segment = @head
    #     else
    #         segment = @head.next

    #     while segment
    #         if segment.x == x and segment.y == y
    #             return true
    #         segment = segment.next
    #     return false

    # checkPointIsOccupied: (point) ->
    #     segment = @head.next

    #     while segment
    #         if segment.x == point.x and segment.y == point.y
    #             return true

    #         if point.x > 59 or point.x < 0 or point.y < 0 or point.y > 39
    #             return true

    #         segment = segment.next
    #     return false

    countNeighbours: (point) ->
        result = 0
        if @checkPointIsOccupied new Point(point.x, point.y+1) then result++
        if @checkPointIsOccupied new Point(point.x, point.y-1) then result++
        if @checkPointIsOccupied new Point(point.x+1, point.y) then result++
        if @checkPointIsOccupied new Point(point.x-1, point.y) then result++
        result
  


class Game
    constructor: ->
        # @armKeyboard()
        @canvas = new Canvas
        @board = new Board

        @snake = new Snake
        @snake.project @board

        @food = @addFood @board
        @food.project @board

        @canvas.paint @board

        processCallback = @process.bind(this)
        @processing = setInterval processCallback, 30

    # armKeyboard: ->
    #     document.addEventListener 'keydown', (e) =>
    #         if e.keyCode == 37 and @snake.direction != 'right' then @snake.direction = 'left'
    #         if e.keyCode == 39 and @snake.direction != 'left' then @snake.direction = 'right'
    #         if e.keyCode == 38 and @snake.direction != 'down' then @snake.direction = 'up'
    #         if e.keyCode == 40 and @snake.direction != 'up' then @snake.direction = 'down'
          
    checkCollision: ->
        if @snake.head.x == @food.x and @snake.head.y == @food.y
            console.log 'eaten'
            @snake.extra = @food.value
            @food = @addFood @board

        # if @snake.bitHimself(@snake.head.x, @snake.head.y, false)
        #     @gameOver()
        #     return true

        if @snake.head.x < 0 or @snake.head.x >= width or @snake.head.y < 0 or @snake.head.y >= height
            @gameOver()
            return true
        false 


    addFood: (board) ->
        # draw random position on board - but not occupied by any snake segment
        loop
            x = randomInt(0, width-1)
            y = randomInt(0, height-1)

            if board.get(x, y) == 0
                return new Food(x, y, 3)

    gameOver: () ->
        clearInterval @processing
        document.getElementsByTagName('body')[0].className += ' tragedy'

    process: ->
        # @think()

        @snake.move()

        if @checkCollision()
            return

        # @canvas.clear()

        @board.clear()
        @snake.project @board
        @food.project @board

        @canvas.paint @board

        # @food.paint(@canvas.ctx)
        # console.log @snake.head.x, @snake.head.y

    checkFourPointsAround: (point) ->
        # ta funkcja musi wiedzieć co jest już zajęte przez zamalowane punkty, nie tylko węża
        # jak to zrobić - pierwsza myśl albo rekurencja??? - albo muszę pamiętać z której strony powstał punkt?
        # albo mieć listę punktów i sprawdzać węża, border i te punkty - może tak byłoby najłatwiej

    checkForClosedSpace: (direction) ->
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

    think: () ->
        x = @snake.head.x
        y = @snake.head.y

        directions = 
            up: new Point(x, y-1)
            down: new Point(x, y+1)
            left: new Point(x-1, y)
            right: new Point(x+1, y)

        # if some direction is illegal it will be deleted - like snake body or outside the board
        for own key, value of directions
            if @snake.checkPointIsOccupied value
                delete directions[key]

        # filter directions instead of distances
        for own key, value of directions
            if @checkForClosedSpace value
                delete directions[key]

        distances = []


        for own key, value of directions
            distance = @food.distance(value)
            neighbours = @snake.countNeighbours(value)
            if neighbours < 3
                distances.push([key, distance])



        distances.sort (a, b) ->
            a[1] - b[1]

        if distances.length > 0
            @snake.direction = distances[0][0]


    # think2: () ->
    #     x = @snake.head.x
    #     y = @snake.head.y

    #     directions = 
    #         up: new Point(x, y-1)
    #         down: new Point(x, y+1)
    #         left: new Point(x-1, y)
    #         right: new Point(x+1, y)


    #     # if some direction is illegal it will be deleted - like snake body or outside the board
    #     for own key, value of directions
    #         if @snake.checkPointIsOccupied value
    #             delete directions[key]

    #     distances = []

    #     for own key, value of directions
    #         distance = @food.distance(value)
    #         neighbours = @snake.countNeighbours(value)
    #         if neighbours < 3
    #             distances.push([key, distance])

    #     distances.sort (a, b) ->
    #         a[1] - b[1]

    #     if distances.length > 1 and @snake.direction == distances[1][0] and @snake.lastDistance > distances[1][1]
    #         @snake.lastDistance = distances[1][1]
    #         bestWay = distances[1][0]
    #     else 
    #         bestWay = distances[0][0]
    #         if distances.length > 1
    #             @snake.lastDistance = distances[0][0]

    #     if bestWay
    #         @snake.direction = bestWay

window.start = () ->
    game = new Game
