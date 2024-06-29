using Sockets
using DebugAdapter
using Logging

function start_debugger()
    server_port = parse(Int, ARGS[1])

    server = Sockets.listen(server_port)

    conn = Sockets.accept(server)
    debugsession = DebugAdapter.DebugSession(conn)

    run(debugsession)

    close(conn)
end

start_debugger()