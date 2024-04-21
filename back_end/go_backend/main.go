package main

import (
	"net/http"
	"web-service/util"

	"github.com/gin-gonic/gin"
)

func main() {
	router := gin.Default()
	router.GET("/", getRoutes)
	router.POST("/v1/config", util.PostConfig)

	router.POST("/v2/user", util.CreateUser)

	router.GET("/v2/session/:user/:password", util.CheckUser)
	// router.POST("/v2/session", util.CheckUser)

	router.Run(":8080")
}

func getRoutes(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"routes": []string{"/ [GET]", "/v1/config [POST]", "/v2/user [POST]", "/v2/session/:user/:password [GET]"},
	})
}
