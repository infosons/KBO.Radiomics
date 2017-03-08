radiomicaRunFun <- function(xrange) {
  killSelf<-function() tools::pskill(Sys.getpid())
  write(Sys.getpid(),"lock")
  source("persistenza.R")
  run <-function() {
    pendingJobs<-executeQuery("SELECT rr.id, p.cartella_immagini, rr.roi_moddicom as roi, rr.filtro,rr.sigma FROM Radiomica_Run rr INNER JOIN Paziente p ON p.id=rr.id_paziente WHERE status='pending'")
    for (i in xrange(nrow(pendingJobs))) {
      job<-pendingJobs[i,]
      obj <- moddicomV2::geoLet()
      obj$openDICOMFolder(pathToOpen = job[["cartella_immagini"]])
      filter=job[["filtro"]]
      sigma=job[["sigma"]]
      vc<-moddicomV2::FIL.getFilteredVoxelCube(obj.geoLet = obj,ROIName = job[["roi"]],kind.of.filter = filter,sigma = sigma)
      output<-moddicomV2::RAD.ExtractFeatures(obj.geoLet = obj,voxelCube = vc)
      rawRepresenstation<-serialize(output,NULL,TRUE)
      stringRepresentation<-rawToChar(rawRepresenstation,FALSE)
      if (file.exists("lock")) {
        if (scan("lock")!=Sys.getpid()) {
          killSelf()
        }
      }
      else {
        killSelf()
      }
      updateQuery<-sprintf("UPDATE Radiomica_Run SET data='%s', status='done' WHERE id=%i",stringRepresentation,job[["id"]])
      executeQuery(updateQuery)
    }
  }
  tryCatch({
    run()
  },
  error = function(e) {
    write(as.character(e),"error")
  },
  finally = {
    if (file.exists("lock")) {
      file.remove("lock") 
    }
    killSelf()
  })
}