package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"time"
)

func handler(w http.ResponseWriter, r *http.Request) {
	file, _, err := r.FormFile("input.png")
	if err != nil {
		log.Fatal(err)
	}

	data, err := ioutil.ReadAll(file)
	if err != nil {
		log.Fatal(err)
	}

	output := "output/" + time.Now().String() + ".png"
	err = ioutil.WriteFile(output, data, 0777)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Fprintf(w, "done.")
}

func main() {
	http.HandleFunc("/", handler)
	http.ListenAndServe(":3000", nil)
}
