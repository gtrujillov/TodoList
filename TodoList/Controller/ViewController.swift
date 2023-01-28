//
//  ViewController.swift
//  TodoList
//
//  Created by gonzalo trujillo vallejo on 27/1/23.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    //Lista de tareas
    var listaDeTareas = [Tarea]()
    // Asignamos el contexto de persistencia del contenedor de la aplicación a la variable "context"
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var tablaTareas: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Establecemos el delegado y el origen de datos de la tabla "tablaTareas" como si misma
        tablaTareas.delegate = self
        tablaTareas.dataSource = self
        /*La línea de código establece el delegado y el origen de datos de una tabla llamada "tablaTareas" como si misma, lo que significa que la clase en la que se encuentra este código será la encargada de proporcionar y manejar la información mostrada en la tabla, así como recibir y manejar eventos generados por la tabla.*/
        
        //Cuando la app carga, llama al metodo leerTareas para recuperar los datos
        let solicitud : NSFetchRequest<Tarea> = Tarea.fetchRequest()
        leerTareas(with: solicitud)
        
    }
    
    // Si el botón "nuevaTarea" es pulsado, se crea una alerta
    @IBAction func nuevaTarea(_ sender: UIBarButtonItem) {
        // Variable para almacenar el texto ingresado en el recuadro de la alerta
        var nombreTarea = UITextField()
        
        // Se crea la alerta
        let alerta = UIAlertController(title: "Nueva tarea", message: "Tarea", preferredStyle: .alert)
        
        // Acción para aceptar la creación de la nueva tarea
        let accionAceptar = UIAlertAction(title: "Añadir", style: .default) { accion in
            // Se crea una nueva tarea y se asigna el nombre ingresado en la alerta
            let nuevaTarea = Tarea(context: self.context)
            nuevaTarea.title = nombreTarea.text
            nuevaTarea.done = false
            
            // Se añade la nueva tarea a la lista de tareas
            self.listaDeTareas.append(nuevaTarea)
            
            // Se guardan los cambios
            self.guardar()
        }
        
        // Se añade un campo de texto a la alerta para ingresar el nombre de la tarea
        alerta.addTextField { textFieldAlerta in
            textFieldAlerta.placeholder = "Escribe el nombre de la terea"
            nombreTarea = textFieldAlerta
        }
        
        // Se añade la acción de aceptar a la alerta
        alerta.addAction(accionAceptar)
        
        // Se presenta la alerta en pantalla
        present(alerta, animated: true)
        
    }
    
    
    // Esta función guarda los cambios en el contexto de Core Data
    func guardar(){
        do{
            // Se intenta guardar los cambios en el contexto
            try context.save()
        }catch{
            print("Error guardando los cambios \(error)")
        }
        // Se actualiza la tabla de tareas para reflejar los cambios
        self.tablaTareas.reloadData()
    }
    
    // Esta función lee las tareas almacenadas en Core Data
    func leerTareas(with solicitud: NSFetchRequest<Tarea>){
        do {
            // Se intenta leer las tareas mediante la solicitud creada
            listaDeTareas = try context.fetch(solicitud)
        }catch{
            print("Error solicitando los datos \(error.localizedDescription)")
        }
    }
}

//MARK: - Extension para controlar las acciones de la tabla
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaDeTareas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tablaTareas.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let tarea = listaDeTareas[indexPath.row]
        
        //Operador ternario
        celda.textLabel?.text = tarea.title
        celda.textLabel?.textColor = tarea.done ? .black : .blue
        celda.detailTextLabel?.text = tarea.done ? "Completada" : "Sin completar"
        
        //Marcar con un check si la tarea está completada o no
        celda.accessoryType = tarea.done ? .checkmark : .none
        
        return celda
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tablaTareas.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tablaTareas.cellForRow(at: indexPath)?.accessoryType = .none
        }else{
            tablaTareas.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        //Editar en coredata
        listaDeTareas[indexPath.row].done = !listaDeTareas[indexPath.row].done
        
        //Guardamo los cambios
        guardar()
        
        //Deseleccionar tarea
        tablaTareas.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let accionEliminar = UIContextualAction(style: .normal, title: "Eliminar") { _, _, _ in
            self.context.delete(self.listaDeTareas[indexPath.row])
            self.listaDeTareas.remove(at: indexPath.row)
            
            //Guardamos los cambios en la base de datos
            self.guardar()
        }
        //Color al eliminar elemento
        accionEliminar.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [accionEliminar])
    }
    
}

//MARK: - Extension para controlar las acciones de la barra de búsqueda
extension ViewController: UISearchBarDelegate {
    
    //funcion para buscar elementos en la lista
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Se crea una solicitud para leer entidades de tipo Tarea
        let solicitud : NSFetchRequest<Tarea> =  Tarea.fetchRequest()
        // Crea un predicado que filtre los resultados según el texto ingresado en la barra de búsqueda.
        solicitud.predicate = NSPredicate(format: "title CONTAINS[cd] %@" , searchBar.text!)
        
        let ordenDeElementos = NSSortDescriptor(key: "title", ascending: true)
        let resultadosOrdenados = listaDeTareas.sorted(by: { ($0.title ?? "") < ($1.title ?? "") })
        
        leerTareas(with: solicitud)
        tablaTareas.reloadData()
    }
    
    //funcion para volver a la lista inicial de elementos
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Se crea una solicitud para leer entidades de tipo Tarea
        let solicitud : NSFetchRequest<Tarea> =  Tarea.fetchRequest()
        if searchBar.text?.count == 0 {
            leerTareas(with: solicitud)
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        tablaTareas.reloadData()
    }
}

