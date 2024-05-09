package main

import (
	"net/http"
	"web-service/util"

	"github.com/gin-gonic/gin"
)

func main() {
	router := gin.Default()
	router.GET("/", getRoutes)
	router.POST("/v1/config", util.PostConfigV1)
	router.POST("/v2/config", util.PostConfigV2)

	router.POST("/v2/user", createUser)

	router.GET("/v2/session/:user/:password", checkUser)
	// router.POST("/v2/session", util.CheckUser)

	router.Run(":8080")
}

func getRoutes(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"routes": []string{"/ [GET]", "/v1/config [POST]: {Peripherals[Pin,Name,Value,Type], Request, Result, Result_Datatype}", "/v2/config [POST]: {{Peripherals[Pin,Name,Value,Type], Request, Result, Result_Datatype}, Username}", "/v2/user [POST]", "/v2/session/:user/:password [GET]"},
	})
}

func createUser(c *gin.Context) {
	var user util.User
	if err := c.BindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	err, res := util.CreateUser(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	}
	c.JSON(http.StatusOK, gin.H{"message": res})
}

func checkUser(c *gin.Context) {
	user := c.Param("user")
	password := c.Param("password")
	err, userItem := util.CheckUser(user, password)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
	}
	c.JSON(http.StatusOK, userItem)
}
