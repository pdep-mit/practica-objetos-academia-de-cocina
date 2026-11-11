// 1. cocinero.experienciaAdquirida()
// 2. cocinero.superoUnNivel(nivelQueMeInteresa)
// 3. cocinero.preparar(unaReceta)
// 4. se agrega RecetaGourmet

// 5. academiaDeCocina.entrenarEstudiantes()
// No lo llegamos a hacer, pero seria algo como
// y que la academia haga un forEach de sus estudiantes y delegue
// para que cada uno entrene con su recetario

class Cocinero {
  const property preparaciones = []
  var nivelActual = principiante

  method experienciaAdquirida() = self.preparaciones().sum {
    comida => comida.experienciaQueDa()
  }
  method superoUnNivel(nivelASuperar) =
    nivelASuperar.superadoPor(self)

  method cantidadDeComidasDificiles() = 
    self.preparaciones().count {comida =>
      comida.esDificil()
    }

  method preparar(receta) {
    nivelActual.validarQuePuedePreparar(receta, self)
    self.agregarPreparacion(nivelActual.preparacionPara(receta, self))
    self.evaluarPasajeDeNivel()
  }
  method agregarPreparacion(comida){
    preparaciones.add(comida)
  }
  method evaluarPasajeDeNivel(){
    if(self.superoUnNivel(nivelActual))
      nivelActual = nivelActual.nivelSiguiente()
  }
}

class Comida {
  const property receta
  const property calidad
  method experienciaQueDa() =
    calidad.ajustarExperiencia(receta.experienciaQueDa())
  method esDificil() = receta.esDificil()
}

class Receta {
  const property ingredientes = #{}
  const property nivelDeDificultad
  method esDificil() 
    = nivelDeDificultad > 5 || self.cantidadDeIngredientes() > 10
  method experienciaQueDa() 
    = self.cantidadDeIngredientes() * self.nivelDeDificultad()
  method cantidadDeIngredientes() = ingredientes.size()

  method mismosIngredientes(otraReceta) 
    = self.ingredientes() == otraReceta.ingredientes()
}

class RecetaGourmet inherits Receta {
  override method experienciaQueDa() = super() * 2
  override method esDificil() = true
}

object normal {
  method ajustarExperiencia(exp) = exp
}

object pobre {
  var experienciaMaxima = 0
  method ajustarExperiencia(exp) = exp.min(experienciaMaxima)
}

class Superior {
  const plusExperiencia
  method ajustarExperiencia(exp) = exp + plusExperiencia
}

///////// Niveles

class Nivel {
  method validarQuePuedePreparar(receta, cocinero) {
    if(!self.puedePreparar(receta, cocinero))
      self.error("No puede preparar la receta")
  }
  method puedePreparar(receta, cocinero) = !receta.esDificil()
  method preparacionPara(receta, cocinero) = 
    new Comida(receta = receta, calidad = self.calidadParaReceta(receta, cocinero))

  // Esto era mas complicado
  method calidadParaReceta(receta, cocinero) = new Superior(plusExperiencia = cocinero.cantComidasSimilares(receta) / 10)
}

object chef inherits Nivel {
  method superadoPor(cocinero) = false
  override method puedePreparar(receta, cocinero) = true
  method nivelSiguiente() {
    self.error("No hay un nivel siguiente")
  }
}

object principiante inherits Nivel {
  method superadoPor(cocinero) 
    = cocinero.experienciaAdquirida() > 100
  override method calidadParaReceta(receta, cocinero) = 
    if(receta.cantidadDeIngredientes() < 4) normal else pobre
  method nivelSiguiente() = experimentado
}

object experimentado inherits Nivel {
  method superadoPor(cocinero) 
    = cocinero.cantidadDeComidasDificiles() > 5

  override method puedePreparar(receta, cocinero) 
    = super(receta, cocinero) || cocinero.cocinoAlgoSimilar(receta)

  method nivelSiguiente() = chef

}
