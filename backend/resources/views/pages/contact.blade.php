@extends('layouts.app')

@section('content')
    <div class="max-w-4xl mx-auto px-4 py-12 grid md:grid-cols-2 gap-8">
        <div>
            <h1 class="text-2xl font-bold mb-4">Contact</h1>
            <p class="mb-2 text-gray-700">Pour toute demande de réservation ou d'information, vous pouvez nous contacter :</p>
            <p class="mb-1 text-sm">Téléphone : {{ $settings->phone ?? '-' }}</p>
            <p class="mb-1 text-sm">WhatsApp : {{ $settings->whatsapp ?? $settings->phone ?? '-' }}</p>
            <p class="mb-1 text-sm">Email : {{ $settings->email ?? '-' }}</p>
            <p class="mb-1 text-sm">Adresse : {{ $settings->address ?? '-' }}</p>
        </div>

        <div>
            <h2 class="text-lg font-semibold mb-3">Formulaire de contact</h2>
            <form method="POST" action="#" class="space-y-3">
                @csrf
                <div>
                    <label class="block text-sm font-medium mb-1">Nom</label>
                    <input type="text" class="w-full border rounded px-3 py-2 text-sm" required>
                </div>
                <div>
                    <label class="block text-sm font-medium mb-1">Email</label>
                    <input type="email" class="w-full border rounded px-3 py-2 text-sm" required>
                </div>
                <div>
                    <label class="block text-sm font-medium mb-1">Message</label>
                    <textarea rows="4" class="w-full border rounded px-3 py-2 text-sm" required></textarea>
                </div>
                <button class="px-4 py-2 bg-emerald-500 hover:bg-emerald-600 text-white text-sm rounded">Envoyer</button>
            </form>
        </div>
    </div>
@endsection
