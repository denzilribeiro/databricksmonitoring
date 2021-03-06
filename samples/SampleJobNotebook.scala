// Databricks notebook source
// Define a simple benchmark util function
def benchmark(name: String)(f: => Unit) {
  val startTime = System.nanoTime
  f
  val endTime = System.nanoTime
  println(s"Time taken in $name: " + (endTime - startTime).toDouble / 1000000000 + " seconds")
}


// COMMAND ----------

// Sum up a billion rows
spark.conf.set("spark.sql.codegen.wholeStage", true)
benchmark("Spark 2.0") {
  spark.range(1000L * 1000 * 1000).selectExpr("sum(id)").show()
}

// COMMAND ----------

// Join 
val df1 = spark.range(10000L).toDF()
df1.count()
spark.range(1000L * 1000 * 1000 * 100 ).join(df1, "id").selectExpr("count(*)").show()

// COMMAND ----------


