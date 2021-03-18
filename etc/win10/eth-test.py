# $language = "Python"
# $interface = "1.0"

CTRL_C = '\x03'
CTRL_Z = '\x1A'
CR = '\x0D'
LF = '\x0A'
CRLF = CR + LF
ENTER = CR

Send = crt.Screen.Send
ReadString = crt.Screen.ReadString
WaitForStrings = crt.Screen.WaitForStrings
MessageBox = crt.Dialog.MessageBox
Sleep = crt.Sleep

def Sendln(cmd, End = ENTER):
    return Send(cmd + End)

def SetSync(sync):
    crt.Screen.Synchronous = sync

def GetResult():
    return crt.Screen.MatchIndex

def FlushRecv():
    while WaitForStrings(' ', 100, bMilliseconds=True): continue


while True:
    Sendln('')
    Sleep(1 * 1000)
    Sendln('')
    Sleep(1 * 1000)
    Sendln('')
    Sleep(1 * 1000)
    Sendln('')
    Sleep(1 * 1000)
    Sendln('')

    while WaitForStrings(['Ruijie>'], 1):
        Sendln('en')
        while WaitForStrings(['Password:'], 1):
            Sendln('1')

    Sendln('')

    # while not WaitForStrings(['Ruijie#'], 1):
    while WaitForStrings(['Ruijie#'], 1):
        Sendln('reload')
        while WaitForStrings(['Reload system?(Y/N)'], 1):
            Sendln('y')

        # Sendln('reload')
        # Sendln('y')

    # Sleep(180 * 1000)


    # Sendln('config')
    # Sendln('int m 0')
    # Sendln('shut')
    # Sleep(5 * 1000)
    # Sendln('no shut')
    # Sleep(5 * 1000)
    # Sendln('speed 100')
    # Sleep(5 * 1000)
    # Sendln('speed 10')
    # Sleep(5 * 1000)
    # Sendln('speed auto')
    # Sleep(5 * 1000)
    # Sendln('en')
    # Sleep(1 * 1000)
    # Sendln('run-system-shell')
    # Sleep(1 * 1000)
    # Sendln('test-char /dev/pmgmt0 getmib')
    # Sleep(1 * 1000)
    # Sendln('test-char /dev/pmgmt0 clearmib')
    # Sleep(1 * 1000)
    # Sendln('exit')
    # Sleep(1 * 1000)

    # while not WaitForStrings(['dut1#','dut2#'], 100, bMilliseconds=True):
    #     Send(' ')
    # Sleep(2 * 1000)
    # Sendln('reset module 12')
    # Sleep(5 * 60 * 1000)
