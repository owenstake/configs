package main

import (
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"syscall"
)

func execCmdexe(cmdstr string) { // exec.Command fail to deal with winpath with space
	// quotedFilename := "'" + filename + "'"
	// quotedFilename := filename
	// quotedFilename := strings.Replace(filename, " ", "^ ", -1)
	// fmt.Println("quote file name is " + quotedFilename)
	// cmd := exec.Command("cmd.exe", "/c", cmdstr, quotedFilename)
	cmd := exec.Command("cmd.exe", "/c", cmdstr)
	// if runtime.GOOS == "windows" {
	// 	cmd.SysProcAttr = &syscall.SysProcAttr{HideWindow: true}
	// }
	buf, err := cmd.CombinedOutput()

	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			status := exitErr.Sys().(syscall.WaitStatus)
			switch {
			case status.Exited():
				fmt.Printf("Return exit error: exit code=%d\n", status.ExitStatus())
			case status.Signaled():
				fmt.Printf("Return exit error: signal code=%d\n", status.Signal())
			}
		} else {
			fmt.Printf("Return other error: %s\n", err)
		}
		fmt.Println(string(buf))
	} else {
		// fmt.Printf("Return OK\n")
		fmt.Println(string(buf))
	}
}

func execCmdexeRaw(commandLine string) {
	// command to execute, may contain quotes, backslashes and spaces
	// var commandLine = `"C:\Program Files\echo.bat" "hello friend"`

	var comSpec = os.Getenv("COMSPEC")
	if comSpec == "" {
		comSpec = os.Getenv("SystemRoot") + "\\System32\\cmd.exe"
	}
	childProcess := exec.Command(comSpec)
	childProcess.SysProcAttr = &syscall.SysProcAttr{CmdLine: comSpec + " /C \"" + commandLine + "\""}

	// Then execute and read the output
	out, _ := childProcess.CombinedOutput()
	fmt.Printf("%s", out)
	// fmt.Println(out)
}

func main() {
	file := os.Args[1]
	bytes, err := os.ReadFile(file)
	if err != nil {
		fmt.Println(err)
		return
	}
	mimeType := http.DetectContentType(bytes) // i.e. text/json
	if err != nil {
		fmt.Println(err)
		return
	}
	switch {
	case strings.Contains(mimeType, "text/"): // text-able file
		file = "\"" + file + "\""
		// execCmdexe("bat --line-range :50 --style plain --pager never --force-colorization " + file)
		execCmdexeRaw("bat --line-range :50 --style plain --pager never --force-colorization " + file)
	default:
		fmt.Println("It's not a text file. Mimetype is", mimeType)
	}
}
