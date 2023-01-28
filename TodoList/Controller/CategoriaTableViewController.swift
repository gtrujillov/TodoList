//
//  CategoriaTableViewController.swift
//  TodoList
//
//  Created by gonzalo trujillo vallejo on 28/1/23.
//

import UIKit
import CoreData

class CategoriaTableViewController: UITableViewController {
    
    //Array de categorias
    var listaCategorias = [Categoria]()
    
    //Contexto
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Tabla con las categorias
    @IBOutlet weak var tablaCategorias: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Cuando la app carga, llama al metodo leerTareas para recuperar los datos
        let solicitud : NSFetchRequest<Categoria> = Categoria.fetchRequest()
        leerCategorias(with: solicitud)
    }
    
    // Esta función guarda los cambios en el contexto de Core Data
    func guardar(){
        do{
            // Se intenta guardar los cambios en el contexto
            try context.save()
        }catch{
            print("Error guardando los cambios \(error)")
        }
        // Se actualiza la tabla de categorias para reflejar los cambios
        self.tablaCategorias.reloadData()
    }
    
    // Esta función lee las tareas almacenadas en Core Data
    func leerCategorias(with solicitud: NSFetchRequest<Categoria>){
        do {
            // Se intenta leer las tareas mediante la solicitud creada
            listaCategorias = try context.fetch(solicitud)
        }catch{
            print("Error solicitando los datos \(error.localizedDescription)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaCategorias.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Celda reutilizable
        let celda = tablaCategorias.dequeueReusableCell(withIdentifier: "CategoriaCell", for: indexPath)
        
        let categoria = listaCategorias[indexPath.row]
        
        celda.textLabel?.text = categoria.name
        
        return celda
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let accionEliminar = UIContextualAction(style: .normal, title: "Eliminar") { _, _, _ in
            self.context.delete(self.listaCategorias[indexPath.row])
            self.listaCategorias.remove(at: indexPath.row)
            
            //Guardamos los cambios en la base de datos
            self.guardar()
        }
        //Color al eliminar elemento
        accionEliminar.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [accionEliminar])
    }
    
    //Nueva categoria
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // Variable para almacenar el texto ingresado en el recuadro de la alerta
        var nombreCategoria = UITextField()
        
        // Se crea la alerta
        let alerta = UIAlertController(title: "Nueva categoria", message: "categoria", preferredStyle: .alert)
        
        // Acción para aceptar la creación de la nueva tarea
        let accionAceptar = UIAlertAction(title: "Añadir", style: .default) { accion in
            // Se crea una nueva categoria y se asigna el nombre ingresado en la alerta
            let nuevaCategoria = Categoria(context: self.context)
            nuevaCategoria.name = nombreCategoria.text
            
            // Se añade la nueva categoria a la lista de tareas
            self.listaCategorias.append(nuevaCategoria)
            
            // Se guardan los cambios
            self.guardar()
        }
        
        // Se añade un campo de texto a la alerta para ingresar el nombre de la tarea
        alerta.addTextField { textFieldAlerta in
            textFieldAlerta.placeholder = "Escribe el nombre de la Categoria"
            nombreCategoria = textFieldAlerta
        }
        
        // Se añade la acción de aceptar a la alerta
        alerta.addAction(accionAceptar)
        
        // Se presenta la alerta en pantalla
        present(alerta, animated: true)
    }
    
    
}


extension CategoriaTableViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Se crea una solicitud para leer entidades de tipo Categoria
        let solicitud : NSFetchRequest<Categoria> =  Categoria.fetchRequest()
        // Crea un predicado que filtre los resultados según el texto ingresado en la barra de búsqueda.
        solicitud.predicate = NSPredicate(format: "name CONTAINS[cd] %@" , searchBar.text!)
        
        let ordenDeElementos = NSSortDescriptor(key: "name", ascending: true)
        let resultadosOrdenados = listaCategorias.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
        
        leerCategorias(with: solicitud)
        tablaCategorias.reloadData()
    }
    
    //funcion para volver a la lista inicial de elementos
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Se crea una solicitud para leer entidades de tipo Categoria
        let solicitud : NSFetchRequest<Categoria> =  Categoria.fetchRequest()
        if searchBar.text?.count == 0 {
            leerCategorias(with: solicitud)
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        tablaCategorias.reloadData()
    }
}
