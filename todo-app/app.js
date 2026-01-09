// Todo App - Main JavaScript

// In-memory storage for tasks
let tasks = [];

// DOM elements
const taskInput = document.getElementById('task-input');
const addBtn = document.getElementById('add-btn');
const taskList = document.getElementById('task-list');

// Add a new task
function addTask() {
    const text = taskInput.value.trim();

    // Validate: don't add empty tasks
    if (!text) {
        return;
    }

    // Create task object with unique ID
    const task = {
        id: Date.now(),
        text: text,
        completed: false
    };

    // Add to array
    tasks.push(task);

    // Render the task
    renderTask(task);

    // Clear input
    taskInput.value = '';
    taskInput.focus();
}

// Toggle task completion
function toggleTask(id) {
    const task = tasks.find(t => t.id === id);
    if (task) {
        task.completed = !task.completed;

        // Update DOM
        const li = document.querySelector(`li[data-id="${id}"]`);
        if (li) {
            li.classList.toggle('completed', task.completed);
        }
    }
}

// Render a single task to the DOM
function renderTask(task) {
    const li = document.createElement('li');
    li.dataset.id = task.id;

    // Apply completed class if task is already completed
    if (task.completed) {
        li.classList.add('completed');
    }

    // Task text span
    const taskText = document.createElement('span');
    taskText.className = 'task-text';
    taskText.textContent = task.text;

    // Click on task text to toggle completion
    taskText.addEventListener('click', function() {
        toggleTask(task.id);
    });

    // Delete button
    const deleteBtn = document.createElement('button');
    deleteBtn.className = 'delete-btn';
    deleteBtn.textContent = '×';
    deleteBtn.type = 'button';

    li.appendChild(taskText);
    li.appendChild(deleteBtn);
    taskList.appendChild(li);
}

// Event listeners
addBtn.addEventListener('click', addTask);

// Handle Enter key in input
taskInput.addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
        addTask();
    }
});
