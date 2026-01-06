@extends('layouts.app')

@section('content')
<div class="min-h-screen bg-gradient-to-br from-amber-50 via-white to-rose-50">
    <!-- Hero Section -->
    <div class="relative bg-gradient-to-r from-amber-600 to-rose-600 text-white py-16 mb-8 overflow-hidden">
        <div class="absolute inset-0 bg-black opacity-10"></div>
        <div class="absolute inset-0" style="background-image: url('data:image/svg+xml,%3Csvg width=\"60\" height=\"60\" viewBox=\"0 0 60 60\" xmlns=\"http://www.w3.org/2000/svg\"%3E%3Cpath d=\"M30 0l30 30-30 30L0 30z\" fill=\"%23ffffff\" fill-opacity=\"0.05\"/%3E%3C/svg%3E'); background-size: 60px 60px;"></div>
        <div class="container mx-auto px-4 relative z-10">
            <h1 class="text-5xl font-bold text-center mb-3 tracking-tight"   style="color:orange">Collection de Caftans</h1>
            <p class="text-center text-amber-100 text-lg"   style="color:orange">Découvrez l'élégance marocaine</p>
        </div>
    </div>

    <div class="container mx-auto px-4 pb-16">
        <div class="flex flex-col lg:flex-row gap-8">
            <!-- Sidebar Filtres -->
            <aside class="lg:w-80 flex-shrink-0">
                <div class="bg-white rounded-2xl shadow-xl p-6 sticky top-4 border border-amber-100">
                    <h2 class="text-2xl font-bold text-gray-800 mb-6 flex items-center">
                        <svg class="w-6 h-6 mr-2 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"/>
                        </svg>
                        Filtres
                    </h2>
                    
                    <form action="{{ route('caftans.index') }}" method="GET" class="space-y-6">
                        <!-- Recherche -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Recherche</label>
                            <div class="relative">
                                <input type="text" 
                                       name="search" 
                                       value="{{ request('search') }}"
                                       placeholder="Nom du caftan..." 
                                       class="w-full pl-10 pr-4 py-3 border-2 border-gray-200 rounded-xl focus:border-amber-500 focus:ring-2 focus:ring-amber-200 transition-all">
                                <svg class="w-5 h-5 text-gray-400 absolute left-3 top-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                                </svg>
                            </div>
                        </div>

                        <!-- Catégorie -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Catégorie</label>
                            <select name="category" 
                                    class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-amber-500 focus:ring-2 focus:ring-amber-200 transition-all bg-white">
                                <option value="">Toutes les catégories</option>
                                @foreach($categories as $category)
                                    <option value="{{ $category->id }}" {{ request('category') == $category->id ? 'selected' : '' }}>
                                        {{ $category->name }}
                                    </option>
                                @endforeach
                            </select>
                        </div>

                        <!-- Prix -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-3">Fourchette de prix</label>
                            <div class="grid grid-cols-2 gap-3">
                                <div>
                                    <input type="number" 
                                           name="min_price" 
                                           value="{{ request('min_price') }}"
                                           placeholder="Min" 
                                           class="w-full px-3 py-2.5 border-2 border-gray-200 rounded-xl focus:border-amber-500 focus:ring-2 focus:ring-amber-200 transition-all text-sm">
                                </div>
                                <div>
                                    <input type="number" 
                                           name="max_price" 
                                           value="{{ request('max_price') }}"
                                           placeholder="Max" 
                                           class="w-full px-3 py-2.5 border-2 border-gray-200 rounded-xl focus:border-amber-500 focus:ring-2 focus:ring-amber-200 transition-all text-sm">
                                </div>
                            </div>
                        </div>

                        <!-- Disponibilité -->
                        <div class="flex items-center">
                            <input type="checkbox" 
                                   name="available_only" 
                                   id="available_only"
                                   {{ request('available_only') ? 'checked' : '' }}
                                   class="w-5 h-5 text-amber-600 border-2 border-gray-300 rounded focus:ring-amber-500 focus:ring-2 transition-all">
                            <label for="available_only" class="ml-3 text-sm font-medium text-gray-700 cursor-pointer">
                                Disponibles uniquement
                            </label>
                        </div>

                        <!-- Bouton -->
                          <button type="submit" 
                                class="w-full bg-gradient-to-r from-orange-400 to-orange-500 text-white py-3.5 px-6 rounded-xl font-semibold hover:from-orange-500 hover:to-orange-600 transform hover:scale-105 transition-all duration-200 shadow-lg hover:shadow-xl"
                                style="background:orange">
                            Appliquer les filtres
                        </button>
                    </form>
                </div>
            </aside>

            <!-- Grille des caftans -->
            <main class="flex-1">
                <div class="mb-6 flex items-center justify-between">
                    <h2 class="text-3xl font-bold text-gray-800">Nos caftans</h2>
                    <div class="text-sm text-gray-600 bg-white px-4 py-2 rounded-full shadow-sm border border-gray-200">
                        {{ $caftans->total() }} résultat(s)
                    </div>
                </div>

                @forelse($caftans as $caftan)
                    <div class="bg-white rounded-2xl shadow-lg hover:shadow-2xl transition-all duration-300 overflow-hidden mb-6 transform hover:-translate-y-1 border border-gray-100">
                        <div class="flex flex-col md:flex-row">
                            <!-- Image -->
                            <div class="md:w-80 h-64 md:h-auto relative overflow-hidden bg-gradient-to-br from-amber-100 to-rose-100">
                                @php $image = $caftan->primaryImage ?: $caftan->images->first(); @endphp

                                @if($image)
                                    <img src="{{ asset('storage/'.$image->image_path) }}" 
                                         alt="{{ $caftan->name }}"
                                         class="w-full h-full object-cover hover:scale-110 transition-transform duration-500">
                                @else
                                    <div class="w-full h-full flex items-center justify-center">
                                        <svg class="w-24 h-24 text-amber-300" fill="currentColor" viewBox="0 0 20 20">
                                            <path fill-rule="evenodd" d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z" clip-rule="evenodd"/>
                                        </svg>
                                    </div>
                                @endif

                                <!-- Badge disponibilité -->
                                <div class="absolute top-4 right-4">
                                    @if($caftan->is_available)
                                        <span class="bg-green-500 text-white px-4 py-2 rounded-full text-sm font-semibold shadow-lg flex items-center">
                                            <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                                            </svg>
                                            Disponible
                                        </span>
                                    @else
                                        <span class="bg-red-500 text-white px-4 py-2 rounded-full text-sm font-semibold shadow-lg flex items-center">
                                            <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
                                            </svg>
                                            Loué
                                        </span>
                                    @endif
                                </div>
                            </div>

                            <!-- Contenu -->
                            <div class="flex-1 p-6 md:p-8 flex flex-col justify-between">
                                <div>
                                    <h3 class="text-2xl font-bold text-gray-800 mb-3">{{ $caftan->name }}</h3>
                                    
                                    @if($caftan->description)
                                        <p class="text-gray-600 mb-4 line-clamp-2">{{ $caftan->description }}</p>
                                    @endif

                                    <div class="flex items-baseline mb-4">
                                        <span class="text-4xl font-bold text-amber-600">{{ $caftan->price_per_day }}</span>
                                        <span class="text-gray-500 ml-2 text-lg">MAD / jour</span>
                                    </div>

                                    @if($caftan->category)
                                        <span class="inline-block bg-amber-100 text-amber-800 px-4 py-1.5 rounded-full text-sm font-medium">
                                            {{ $caftan->category->name }}
                                        </span>
                                    @endif
                                </div>

                                <div class="mt-6">
                                    <a href="{{ route('caftans.show', $caftan) }}" 
                                       class="inline-flex items-center bg-gradient-to-r from-amber-600 to-rose-600 text-white px-8 py-3.5 rounded-xl font-semibold hover:from-amber-700 hover:to-rose-700 transform hover:scale-105 transition-all duration-200 shadow-lg hover:shadow-xl"
                                         style="background:orange">
                                        Voir les détails
                                        <svg class="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                                        </svg>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                @empty
                    <div class="bg-white rounded-2xl shadow-lg p-12 text-center border border-gray-100">
                        <svg class="w-24 h-24 mx-auto text-gray-300 mb-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                        </svg>
                        <h3 class="text-2xl font-bold text-gray-800 mb-2">Aucun caftan trouvé</h3>
                        <p class="text-gray-600 mb-6">Aucun caftan ne correspond à votre recherche.</p>
                        <a href="{{ route('caftans.index') }}" 
                           class="inline-flex items-center text-amber-600 hover:text-amber-700 font-semibold">
                            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                            </svg>
                            Réinitialiser les filtres
                        </a>
                    </div>
                @endforelse

                <!-- Pagination -->
                <div class="mt-8">
                    {{ $caftans->links() }}
                </div>
            </main>
        </div>
    </div>
</div>


<style>
    /* Styles personnalisés pour la pagination Laravel */
    .pagination {
        @apply flex justify-center space-x-2;
    }
    
    .pagination > * {
        @apply px-4 py-2 rounded-lg border transition-all duration-200;
    }
    
    .pagination .active span {
        @apply bg-gradient-to-r from-orange-400 to-orange-500 text-white border-transparent font-semibold shadow-lg;
    }
    
    .pagination a {
        @apply bg-orange text-gray-700 border-gray-300 hover:border-orange-400 hover:bg-orange-50;
    }
    
    .pagination .disabled span {
        @apply bg-gray-100 text-gray-400 border-gray-200 cursor-not-allowed;
    }
</style>
@endsection