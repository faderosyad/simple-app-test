// Special Thanks to Rizky Ramadian Wijaya
package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"golang.org/x/net/context"
	"golang.org/x/oauth2/google"
	sqladmin "google.golang.org/api/sqladmin/v1beta4"
)

type GCPStruct struct {
	SendAPI func() string
}

type InstancesStruct struct {
	databaseInfo func() map[string]string
}

var project = "fade-rosyad-project"
var instance = "testing-on-off"

func onHandler() *GCPStruct {
	return &GCPStruct{
		SendAPI: func() (status string) {
			if CheckInstancesStatus()["activationPolicy"] == "ALWAYS" {
				status = "Database have been turned on"
			} else {
				ChangeActivationPolicy("ALWAYS")
				status = "Turn on Database"
			}
			return
		},
	}
}

func offHandler() *GCPStruct {
	return &GCPStruct{
		SendAPI: func() (status string) {
			if CheckInstancesStatus()["activationPolicy"] == "NEVER" {
				status = "Database have been turned off"
			} else {
				ChangeActivationPolicy("NEVER")
				status = "Turn off Database"
			}
			return
		},
	}
}

func statusHandler() *InstancesStruct {
	return &InstancesStruct{
		databaseInfo: func() map[string]string {
			return CheckInstancesStatus()
		},
	}
}

func (i *InstancesStruct) statusResponse(c *gin.Context) {
	stat := CheckInstancesStatus()
	fmt.Println(stat)
	c.JSON(http.StatusOK, stat)
}

func (g *GCPStruct) handlerResponse(c *gin.Context) {
	res := g.SendAPI()
	c.JSON(http.StatusOK, gin.H{
		"message": res,
	})
}

func ChangeActivationPolicy(status string) {
	ctx := context.Background()

	c, err := google.DefaultClient(ctx, sqladmin.CloudPlatformScope)
	if err != nil {
		log.Fatal(err)
	}

	sqladminService, err := sqladmin.New(c)
	if err != nil {
		log.Fatal(err)
	}

	rb := &sqladmin.DatabaseInstance{
		Settings: &sqladmin.Settings{
			ActivationPolicy: status,
		},
	}

	resp, err := sqladminService.Instances.Patch(project, instance, rb).Context(ctx).Do()
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("%#v\n", resp)
}

func CheckInstancesStatus() (dbinfo map[string]string) {
	ctx := context.Background()

	dbinfo = make(map[string]string)

	c, err := google.DefaultClient(ctx, sqladmin.CloudPlatformScope)
	if err != nil {
		log.Fatal(err)
	}

	sqladminService, err := sqladmin.New(c)
	if err != nil {
		log.Fatal(err)
	}

	resp, err := sqladminService.Instances.Get(project, instance).Context(ctx).Do()
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("%#v\n", resp.Settings.ActivationPolicy)
	dbinfo["databaseName"] = instance
	dbinfo["databaseVersion"] = resp.State
	dbinfo["tier"] = resp.Settings.Tier
	dbinfo["activationPolicy"] = resp.Settings.ActivationPolicy

	return dbinfo
}

func main() {
	r := gin.Default()

	r.GET("/on", onHandler().handlerResponse)
	r.GET("/off", offHandler().handlerResponse)
	r.GET("/status", statusHandler().statusResponse) // handlerResponse nama fungsi

	r.Run() // listen and serve on 0.0.0.0:8080 (for windows "localhost:8080")
}
